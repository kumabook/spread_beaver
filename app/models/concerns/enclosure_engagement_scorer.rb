# frozen_string_literal: true
require("paginated_array")
module EnclosureEngagementScorer
  extend ActiveSupport::Concern

  Enclosures = Enclosure.arel_table
  Join       = Arel::Nodes::OuterJoin
  SCORES_PER_MARK = {
    PlayedEnclosure.table_name => ENV.fetch("PLAYED_SCORE")   { 1 }.to_i,
    LikedEnclosure.table_name  => ENV.fetch("LIKED_SCORE")    { 5 }.to_i,
    SavedEnclosure.table_name  => ENV.fetch("SAVED_SCORE")    { 5 }.to_i,
    EntryEnclosure.table_name  => ENV.fetch("FEATURED_SCORE") { 10 }.to_i,
    Pick.table_name            => ENV.fetch("PICKED_SCORE")   { 20 }.to_i,
  }

  included do
  end

  class_methods do
    def score_per(clazz)
      SCORES_PER_MARK[clazz.table_name]
    end

    def score_per_of(table_name)
      SCORES_PER_MARK[table_name]
    end

    def select_all(select_mgr, bind_values)
      visitor     = ActiveRecord::Base.connection.visitor
      collector   = visitor.accept(select_mgr.ast, Arel::Collectors::Bind.new)
      sql         = collector.substitute_binds(bind_values).join
      ActiveRecord::Base.connection.select_all(sql).to_a
    end

    def score_bind_values(score_tables)
      score_tables.reduce([]) do |memo, t|
        v = t.values[:where].binds.map { |bind|
          ActiveRecord::Base.connection.quote(bind.value_for_database)
        }
        memo.concat v
      end
    end

    def score_select_mgr(score_queries, mix_query)
      score_columns = []
      score_names   = []
      query         = Enclosures
      score_queries.each do |score_query|
        score_name = "#{score_query[:query].table_name}_score"
        scores     = score_table(score_query, mix_query)
        query      = query.join(scores, Join).on(Enclosures[:id].eq(scores[:enclosure_id]))
        column     = "COALESCE(#{scores[:score].sum().to_sql}, 0)"
        score_columns << column
        score_names << "#{column} as #{score_name}"
      end

      score = score_columns.join(" + ")
      query
        .project(Enclosures[:id], *score_names, "#{score} as score")
        .where(Enclosures[:type].eq(self.name))
        .order("score DESC")
        .group(Enclosures[:id])
      query.where(Enclosures[:provider].in(mix_query.provider)) if !mix_query.provider.nil?
      query
    end

    def score_table(score_query, mix_query)
      mark = score_query[:query]
      case score_query[:type]
      when :count
        mark.as("#{mark.table_name}_scores")
      when :time_decayed
        time_decayed_score_table(mark, mix_query.period)
      end
    end

    def time_decayed_score_table(mark, period)
      marks       = mark.arel_table
      table_name  = mark.table_name
      table_alias = mark.as("distinct_#{table_name}")
      per_score   = score_per_of(table_name)
      score       = time_decayed_score(table_alias.table_name,
                                       per_score,
                                       period.twice_past,
                                       1.day.to_i)
      marks.join(table_alias, Join).on(marks[:id].eq(table_alias[:id]))
        .project("#{score} as score, #{table_name}.enclosure_id")
        .group(marks[:enclosure_id])
        .as("#{table_name}_score")
    end

    def most_engaging_items(stream: nil, query: Mix::Query.new, page: 1, per_page: 10)
      score_queries = self.score_table_queries(stream, query)
      score_tables  = score_queries.map { |q| q[:clazz] }

      bind_values   = self.score_bind_values(score_queries.map { |q| q[:query] })

      total_count   = Enclosure.where(type: self.name).provider(query.provider).count

      select_mgr    = self.score_select_mgr(score_queries, query)

      select_mgr.offset = (page - 1) < 0 ? 0 : (page - 1) * per_page
      select_mgr.limit  = per_page

      scores       = self.select_all(select_mgr, bind_values)
      items        = self.with_content.find(scores.map { |h| h["id"] })
      sorted_items = self.sort_items(items, scores, score_tables)
      PaginatedArray.new(sorted_items, total_count, page, per_page)
    end

    def score_table_queries(stream, query)
      played    = self.query_for_best_items(PlayedEnclosure, nil, query)
                    .select("COUNT(played_enclosures.enclosure_id) * #{score_per(PlayedEnclosure)} as score, played_enclosures.enclosure_id")
                    .group("enclosure_id")
      liked     = self.query_for_best_items(LikedEnclosure, nil, query)
                    .select("COUNT(liked_enclosures.enclosure_id) * #{score_per(LikedEnclosure)} as score, liked_enclosures.enclosure_id")
                    .group("enclosure_id")
      saved     = self.query_for_best_items(SavedEnclosure, nil, query)
                    .select("COUNT(saved_enclosures.enclosure_id) * #{score_per(SavedEnclosure)} as score, saved_enclosures.enclosure_id")
                    .group("enclosure_id")
      # doesn't support locale, use stream filter instead
      featured  = self.query_for_best_items(EntryEnclosure, stream, query.no_locale)
                    .joins(:entry)
                    .distinct()
                    .select("COUNT(entries.feed_id) * #{score_per(EntryEnclosure)} as score, entry_enclosures.enclosure_id")
                    .group("entries.feed_id")
                    .group(:enclosure_id)
      # Pick doesn't support locale,
      # don't use stream,
      # excludes sound cloud from provider,
      # uses time decayed score
      pick_query = query.no_locale.twice_past.exclude_sound_cloud
      pick_stream = nil
      if query.use_stream_for_pick
        if stream.kind_of?(Topic)
          # NOTE: In order to improve performance,
          # cache playlist of a topic to mix_issues of the topic
          mix_journal = stream.mix_journal
          if mix_journal.present?
            pick_stream = stream.mix_issues(mix_journal, pick_query.period)
          end
        else
          pick_stream = stream
        end
      end
      picked = self.query_for_best_items(Pick, pick_stream, pick_query)
                 .distinct(:container_id)
      [
        { type: :count       , query: played  , clazz: PlayedEnclosure },
        { type: :count       , query: liked   , clazz: LikedEnclosure },
        { type: :count       , query: saved   , clazz: SavedEnclosure },
        { type: :count       , query: featured, clazz: EntryEnclosure },
        { type: :time_decayed, query: picked  , clazz: Pick }
      ]
    end

    def time_decayed_score(table_name, score, period, precision=nil)
      to       = period.end == Float::INFINITY ? "'#{Time.now.iso8601}'" : "'#{period.end.iso8601}'"
      interval = period.interval
      elapsed_time = "EXTRACT(EPOCH FROM TIMESTAMP WITH TIME ZONE #{to} - #{table_name}.created_at)"

      if precision.present?
        interval     = period.interval / precision
        elapsed_time = "FLOOR(#{elapsed_time} / #{precision})"
      end
      "SUM((#{interval} - #{elapsed_time}) / #{interval} * #{score})"
    end

    def sort_items(items, scores, score_tables)
      scores.map do |h|
        item = items.select { |t| t.id == h["id"] }.first
        item.engagement = h["score"].to_f
        item.scores = score_tables.reduce({}) do |memo, t|
          value = h["#{t.table_name}_score"].to_f
          memo[t.table_name] = {
            value: value,
            count: value / SCORES_PER_MARK[t.table_name].to_f,
          }
          memo
        end
        item
      end
    end
  end
end
