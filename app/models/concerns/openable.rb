require('paginated_array')

module Openable
  extend ActiveSupport::Concern
  def self.included(base)
    attr_accessor :is_opened

    opens = "opened_#{base.table_name}".to_sym
    base.has_many opens, dependent: :destroy
    base.has_many :openers, through: opens, source: :user

    base.scope :hot,    ->        { joins(:users).order('opened_count DESC') }
    base.scope :opened, -> (user) { joins(:openers).where(users: { id: user.id }) }
    base.extend(ClassMethods)
  end

  module ClassMethods
    def open_class
      "Opened#{table_name.singularize.capitalize}".constantize
    end

    def user_opened_hash(user, items)
      marks_hash_of_user(open_class, user, items)
    end

    def hot_items_within_period(from: nil, to: nil, page: 1, per_page: nil)
      best_items_within_period(clazz: self.open_class,
                               from: from, to: to,
                               page: page, per_page: per_page)
    end
  end
end
