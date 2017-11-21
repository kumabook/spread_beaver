require('paginated_array')

module Playable
  extend ActiveSupport::Concern
  included do
    attr_accessor :is_played

    plays = "played_#{table_name}".to_sym
    has_many plays, dependent: :destroy

    scope :hot,    ->        { joins(:users).order('play_count DESC') }
    scope :played, -> (user) {
      joins(plays).where(plays => { user_id: user.id }).order("#{plays}.created_at DESC")
    }
  end

  class_methods do
    def play_class
      "Played#{table_name.singularize.capitalize}".constantize
    end

    def user_played_hash(user, items)
      marks_hash_of_user(play_class, user, items)
    end

    def hot_items(stream:   nil,
                  period:   nil,
                  locale:   nil,
                  provider: nil,
                  page:     1,
                  per_page: nil)
      best_items(clazz:    self.play_class,
                 stream:   stream,
                 period:   period,
                 locale:   locale,
                 provider: provider,
                 page:     page,
                 per_page: per_page)
    end
  end
end
