require('paginated_array')

module Openable
  extend ActiveSupport::Concern
  def self.included(base)
    opens = "opened_#{base.table_name}".to_sym
    base.has_many opens, dependent: :destroy
    base.has_many :opened_users, through: opens, source: :user
    base.alias_attribute :opens, opens

    base.scope :most_open, ->        { eager_load(:users).order('opened_count DESC') }
    base.scope :opened,    ->  (uid) { eager_load(:users).where(users: { id: uid }) }
    base.extend(ClassMethods)
  end

  module ClassMethods
    def open_class
      "Opened#{table_name.singularize.capitalize}".constantize
    end
  end
end
