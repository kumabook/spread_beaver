module Enclosure
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)

    enclosures = "entry_#{base.table_name}".to_sym
    base.has_many enclosures, dependent: :destroy
    base.has_many :entries  , through: enclosures

    base.scope :latest,  -> (time) { where("created_at > ?", time).order('created_at DESC') }
    base.scope :detail,  ->        { eager_load(:users).eager_load(:entries) }

  end

  module ClassMethods
  end
end
