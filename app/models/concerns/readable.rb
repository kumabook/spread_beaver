require('paginated_array')

module Readable
  extend ActiveSupport::Concern
  def self.included(base)
    attr_accessor :is_read

    reads = "read_#{base.table_name}".to_sym
    base.has_many reads, dependent: :destroy
    base.scope :hot , ->      { joins(:users).order('read_count DESC') }
    base.scope :read, -> (user) { joins(reads).where(reads => { user_id: user.id }) }
    base.extend(ClassMethods)
  end

  module ClassMethods
    def read_class
      "Read#{table_name.singularize.capitalize}".constantize
    end

    def user_read_hash(user, items)
      marks_hash_of_user(read_class, user, items)
    end

    def hot_items_within_period(from: nil, to: nil, page: 1, per_page: nil)
      best_items_within_period(clazz: self.read_class,
                               from: from, to: to,
                               page: page, per_page: per_page)
    end
  end
end
