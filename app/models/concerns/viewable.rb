# frozen_string_literal: true

module Viewable
  extend ActiveSupport::Concern
  class_methods do
    def hot_items(stream: nil, query: nil, page: 1, per_page: nil)
      count_hash = self.query_for_best_items(self.view_class, stream, query).user_count
      Mix.items_from_count_hash(self, count_hash, page: page, per_page: per_page)
    end
  end
end
