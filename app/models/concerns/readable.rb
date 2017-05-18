require('paginated_array')

module Readable
  extend ActiveSupport::Concern
  included do
    attr_accessor :is_read

    reads = "read_#{table_name}".to_sym
    has_many reads, dependent: :destroy
    scope :hot , ->      { joins(:users).order('read_count DESC') }
    scope :read, -> (user) {
      joins(reads).where(reads => { user_id: user.id }).order("#{reads}.created_at DESC")
    }
  end

  class_methods do
    def read_class
      "Read#{table_name.singularize.capitalize}".constantize
    end

    def user_read_hash(user, items)
      marks_hash_of_user(read_class, user, items)
    end

    def hot_items_within_period(period: nil, page: 1, per_page: nil)
      best_items_within_period(clazz: self.read_class,
                               period: period,
                               page: page, per_page: per_page)
    end
  end
end
