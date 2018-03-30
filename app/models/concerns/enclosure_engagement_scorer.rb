require('paginated_array')
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

    def score_select_mgr(score_tables)
      score_columns = []
      score_names   = []
      query         = Enclosures
      score_tables.each do |mark|
        scores = mark.as("#{mark.table_name}_scores")
        query  = query.join(scores, Join).on(Enclosures[:id].eq(scores[:enclosure_id]))
        column = "COALESCE(#{scores[:score].sum().to_sql}, 0)"
        score_columns << column
        score_names << "#{column} as #{mark.table_name}_score"
      end

      score = score_columns.join(' + ')
      query
        .project(Enclosures[:id], *score_names, "#{score} as score")
        .where(Enclosures[:type].eq(self.name))
        .order("score DESC")
        .group(Enclosures[:id])
    end

    def most_engaging_items(stream: nil, query: Mix::Query.new, page: 1, per_page: 10)
      score_tables = self.score_table_queries(stream, query)
      bind_values  = self.score_bind_values(score_tables)

      total_count  = Enclosure.where(type: self.name).count

      select_mgr   = self.score_select_mgr(score_tables)

      select_mgr.offset = (page - 1) < 0 ? 0 : (page - 1) * per_page
      select_mgr.limit  = per_page

      scores       = self.select_all(select_mgr, bind_values)
      items        = self.with_content.find(scores.map {|h| h["id"] })
      sorted_items = self.sort_items(items, scores, score_tables)
      PaginatedArray.new(sorted_items, total_count, page, per_page)
    end

    def score_table_queries(stream, query)
      played    = self.query_for_best_items(PlayedEnclosure, stream, query)
                    .select("COUNT(played_enclosures.enclosure_id) * #{score_per(PlayedEnclosure)} as score, played_enclosures.enclosure_id")
                    .group("enclosure_id")
      liked     = self.query_for_best_items(LikedEnclosure, stream, query)
                    .select("COUNT(liked_enclosures.enclosure_id) * #{score_per(LikedEnclosure)} as score, liked_enclosures.enclosure_id")
                    .group("enclosure_id")
      saved     = self.query_for_best_items(SavedEnclosure, stream, query)
                    .select("COUNT(saved_enclosures.enclosure_id) * #{score_per(SavedEnclosure)} as score, saved_enclosures.enclosure_id")
                    .group("enclosure_id")
      # doesn't support locale, use stream filter instead
      featured  = self.query_for_best_items(EntryEnclosure, stream, query.no_locale)
                    .joins(:entry)
                    .distinct()
                    .select("COUNT(entries.feed_id) * #{score_per(EntryEnclosure)} as score, entry_enclosures.enclosure_id")
                    .group("entries.feed_id")
                    .group(:enclosure_id)
      # doesn't support locale, use stream filter instead
      picked    = self.query_for_best_items(Pick, stream, query.no_locale)
                    .select("COUNT(container_id) * #{score_per(Pick)} as score, picks.enclosure_id")
                    .group(:enclosure_id)
      [played, liked, saved, featured, picked]
    end

    def sort_items(items, scores, score_tables)
      scores.map do |h|
        item = items.select { |t| t.id == h["id"] }.first
        item.engagement = h["score"].to_i
        item.scores = score_tables.reduce({}) do |memo, t|
          value = h["#{t.table_name}_score"].to_i
          memo[t.table_name] = {
            value: value,
            count: value / SCORES_PER_MARK[t.table_name],
          }
          memo
        end
        item
      end
    end
  end
end
