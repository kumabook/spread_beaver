require('paginated_array')

module Savable
  extend ActiveSupport::Concern
  def self.included(base)
    attr_accessor :is_saved

    saves = "saved_#{base.table_name}".to_sym
    base.has_many saves, dependent: :destroy
    base.has_many :saved_users, through: saves, source: :user

    base.scope :saved, ->  (user) {
      joins(:saved_users).where(users: { id: user.id }).order("#{saves}.created_at DESC")
    }
    base.extend(ClassMethods)
  end

  module ClassMethods
    def save_class
      "Saved#{table_name.singularize.capitalize}".constantize
    end

    def user_saved_hash(user, items)
      marks_hash_of_user(save_class, user, items)
    end
  end
end
