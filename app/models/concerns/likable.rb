# frozen_string_literal: true

require("paginated_array")

module Likable
  extend ActiveSupport::Concern
  included do
    attr_accessor :is_liked

    likes = "liked_#{table_name}".to_sym
    has_many likes, dependent: :destroy
    has_many :likers, through: likes, source: :user

    scope :popular, ->        { joins(:users).order("likes_count DESC") }
    scope :liked,   ->(user) {
      joins(:likers).where(users: { id: user.id }).order("#{likes}.created_at DESC")
    }
  end

  class_methods do
    def like_class
      "Liked#{table_name.singularize.capitalize}".constantize
    end

    def user_liked_hash(user, items)
      marks_hash_of_user(like_class, user, items)
    end

    def popular_items(stream: nil, query: nil, page: 1, per_page: PER_PAGE)
      count_hash = query_for_best_items(like_class, stream, query).user_count
      Mix.items_from_count_hash(self, count_hash, page: page, per_page: per_page)
    end
  end
end
