# frozen_string_literal: true

require("paginated_array")

module Readable
  extend ActiveSupport::Concern
  included do
    include Viewable
    attr_accessor :is_read, :unread

    reads = read_class.table_name.to_sym
    has_many reads, read_class.mark_has_many_options

    scope :hot , ->      { joins(:users).order("read_count DESC") }
    scope :read, ->(user) {
      joins(reads).where(reads => { user_id: user.id }).order("#{reads}.created_at DESC")
    }
  end

  class_methods do
    def read_class
      if self == Entry
        ReadEntry
      else
        ReadEnclosure
      end
    end
    alias_method :view_class, :read_class

    def user_read_hash(user, items)
      marks_hash_of_user(read_class, user, items)
    end
  end
end
