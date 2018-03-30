require('paginated_array')

module Readable
  extend ActiveSupport::Concern
  included do
    attr_accessor :is_read, :unread

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

    def hot_items(stream: nil, query: nil, page: 1, per_page: nil)
      count_hash = self.query_for_best_items(self.read_class, stream, query).user_count
      Mix::items_from_count_hash(self, count_hash, page: page, per_page: per_page)
    end
  end
end
