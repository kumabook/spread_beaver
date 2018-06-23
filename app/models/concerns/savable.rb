# frozen_string_literal: true

require("paginated_array")

module Savable
  extend ActiveSupport::Concern
  included do
    attr_accessor :is_saved

    saves = save_class.table_name.to_sym
    has_many saves, save_class.mark_has_many_options
    has_many :saved_users, through: saves, source: :user

    scope :saved, ->(user) {
      joins(:saved_users).where(users: { id: user.id }).order("#{saves}.created_at DESC")
    }
  end

  class_methods do
    def save_class
      if self == Entry
        SavedEntry
      else
        SavedEnclosure
      end
    end

    def user_saved_hash(user, items)
      marks_hash_of_user(save_class, user, items)
    end
  end
end
