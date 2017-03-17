require('paginated_array')

module Likable
  extend ActiveSupport::Concern
  def self.included(base)
    likes = "liked_#{base.table_name.singularize}".to_sym
    base.has_many likes, dependent: :destroy
    base.has_many :users, through: likes
    base.alias_attribute :likes, likes

    base.scope :popular, ->        { eager_load(:users).order('saved_count DESC') }
    base.scope :liked,   ->  (uid) { eager_load(:users).where(users: { id: uid }) }
    base.extend(ClassMethods)
  end

  module ClassMethods
    def like_class
      "Liked#{table_name.singularize.capitalize}".constantize
    end

    def popular_items_within_period(from: nil, to: nil, page: 1, per_page: nil)
      self.best_items_within_period(clazz: self.like_class,
                                    from: from, to: to,
                                    page: page, per_page: per_page)
    end
  end
end
