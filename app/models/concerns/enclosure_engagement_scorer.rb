require('paginated_array')
module EnclosureEngagementScorer
  extend ActiveSupport::Concern

  Enclosures = Enclosure.arel_table
  Join       = Arel::Nodes::OuterJoin

  included do
  end

  class_methods do
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
      query         = Enclosures
      score_tables.each do |mark|
        scores = mark.as("#{mark.table_name}_scores")
        query  = query.join(scores, Join).on(Enclosures[:id].eq(scores[:enclosure_id]))
        score_columns << "COALESCE(#{scores[:score].sum().to_sql}, 0)"
      end

      score = score_columns.join(' + ')
      query
        .project(Enclosures[:id], "#{score} as score")
        .where(Enclosures[:type].eq(self.name))
        .order("score DESC")
        .group(Enclosures[:id])
    end

    def most_engaging_items(stream: nil,
                            locale: nil,
                            period: nil,
                            provider: nil,
                            page: 1,
                            per_page: 10)
      played_score    = ENV.fetch("PLAYED_SCORE")   { 1 }
      liked_score     = ENV.fetch("LIKED_SCORE")    { 5 }
      saved_score     = ENV.fetch("SAVED_SCORE")    { 5 }
      featured_score  = ENV.fetch("FEATURED_SCORE") { 10 }
      picked_score    = ENV.fetch("PICKED_SCORE")   { 20 }

      played    = self.query_for_best_items(PlayedEnclosure, stream, period, locale, provider)
                    .select("COUNT(played_enclosures.enclosure_id) * #{played_score} as score, played_enclosures.enclosure_id")
                    .group("enclosure_id")

      liked     = self.query_for_best_items(LikedEnclosure, stream, period, locale, provider)
                    .select("COUNT(liked_enclosures.enclosure_id) * #{liked_score} as score, liked_enclosures.enclosure_id")
                    .group("enclosure_id")
      saved     = self.query_for_best_items(SavedEnclosure, stream, period, locale, provider)
                    .select("COUNT(saved_enclosures.enclosure_id) * #{saved_score} as score, saved_enclosures.enclosure_id")
                    .group("enclosure_id")
      # doesn't support locale, use stream filter instead
      featured  = self.query_for_best_items(EntryEnclosure, stream, period, nil, provider)
                    .joins(:entry)
                    .distinct()
                    .select("COUNT(entries.feed_id) * #{featured_score} as score, entry_enclosures.enclosure_id")
                    .group("entries.feed_id")
                    .group(:enclosure_id)
      # doesn't support locale, use stream filter instead
      picked    = self.query_for_best_items(Pick, stream, period, nil, provider)
                    .select("COUNT(container_id) * #{picked_score} as score, picks.enclosure_id")
                    .group(:enclosure_id)

      score_tables = [played, liked, saved, featured, picked]
      bind_values  = self.score_bind_values(score_tables)

      total_count  = Enclosure.where(type: self.name).count

      select_mgr   = self.score_select_mgr(score_tables)

      select_mgr.offset = (page - 1) < 0 ? 0 : (page - 1) * per_page
      select_mgr.limit  = per_page

      scores      = self.select_all(select_mgr, bind_values)
      items = self.with_content.find(scores.map {|h| h["id"] })

      sorted_items = scores.map do |h|
        item = items.select { |t| t.id == h["id"] }.first
        item.engagement = h["score"]
        item
      end
      PaginatedArray.new(sorted_items, total_count)
    end
  end
end
