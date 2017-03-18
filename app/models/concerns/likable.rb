require('paginated_array')

module Likable
  extend ActiveSupport::Concern
  def self.included(base)
    attr_accessor :is_liked

    likes = "liked_#{base.table_name}".to_sym
    base.has_many likes, dependent: :destroy
    base.has_many :users, through: likes
    base.alias_attribute :likes, likes

    base.scope :popular, ->        { joins(:users).order('liked_count DESC') }
    base.scope :liked,   -> (user) { joins(:users).where(users: { id: user.id }) }
    base.extend(ClassMethods)
  end

  module ClassMethods
    def like_class
      "Liked#{table_name.singularize.capitalize}".constantize
    end

    def user_liked_hash(user, items)
      marks_hash_of_user(like_class, user, items)
    end

    def popular_items_within_period(from: nil, to: nil, page: 1, per_page: nil)
      best_items_within_period(clazz: self.like_class,
                               from: from, to: to,
                               page: page, per_page: per_page)
    end
  end
end
