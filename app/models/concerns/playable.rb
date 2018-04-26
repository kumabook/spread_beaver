# frozen_string_literal: true

require("paginated_array")

module Playable
  extend ActiveSupport::Concern
  included do
    include Viewable
    attr_accessor :is_played

    plays = "played_#{table_name}".to_sym
    has_many plays, dependent: :destroy

    scope :hot,    ->        { joins(:users).order("play_count DESC") }
    scope :played, ->(user) {
      joins(plays).where(plays => { user_id: user.id }).order("#{plays}.created_at DESC")
    }
  end

  class_methods do
    def play_class
      "Played#{table_name.singularize.capitalize}".constantize
    end
    alias_method :view_class, :play_class

    def user_played_hash(user, items)
      marks_hash_of_user(play_class, user, items)
    end

    def hot_items(stream: nil, query: nil, page: 1, per_page: nil)
      count_hash = query_for_best_items(view_class, stream, query).user_count
      Mix.items_from_count_hash(self, count_hash, page: page, per_page: per_page)
    end
  end
end
