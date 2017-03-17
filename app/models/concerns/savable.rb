require('paginated_array')

module Savable
  extend ActiveSupport::Concern
  def self.included(base)
    saves = "saved_#{base.table_name}".to_sym
    base.has_many saves, dependent: :destroy
    base.has_many :saved_users, through: saves, source: :user
    base.alias_attribute :saves, saves

    base.scope :saved, ->  (user) { joins(saves).where(saves => { user_id: user.id }) }
    base.extend(ClassMethods)
  end

  module ClassMethods
    def save_class
      "Saved#{table_name.singularize.capitalize}".constantize
    end
  end
end
