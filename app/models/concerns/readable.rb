# frozen_string_literal: true

require("paginated_array")

module Readable
  extend ActiveSupport::Concern
  included do
    include Viewable
    attr_accessor :is_read, :unread

    reads = "read_#{table_name}".to_sym
    has_many reads, dependent: :destroy
    scope :hot , ->      { joins(:users).order("read_count DESC") }
    scope :read, -> (user) {
      joins(reads).where(reads => { user_id: user.id }).order("#{reads}.created_at DESC")
    }
  end

  class_methods do
    def read_class
      "Read#{table_name.singularize.capitalize}".constantize
    end
    alias_method :view_class, :read_class

    def user_read_hash(user, items)
      marks_hash_of_user(read_class, user, items)
    end
  end
end
