require('paginated_array')

module Likable
  extend ActiveSupport::Concern
  included do
    attr_accessor :is_liked

    likes = "liked_#{table_name}".to_sym
    has_many likes, dependent: :destroy
    has_many :likers, through: likes, source: :user

    scope :popular, ->        { joins(:users).order('likes_count DESC') }
    scope :liked,   -> (user) {
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

    def popular_items(stream:   nil,
                      period:   nil,
                      locale:   nil,
                      provider: nil,
                      page:     1,
                      per_page: PER_PAGE)
      best_items(clazz:    self.like_class,
                 stream:   stream,
                 period:   period,
                 locale:   locale,
                 provider: provider,
                 page:     page,
                 per_page: per_page)
    end
  end
end
