module Likable
  extend ActiveSupport::Concern
  def self.included(base)
    likes = "#{base.table_name.singularize}_likes".to_sym
    base.has_many likes, dependent: :destroy
    base.has_many :users, through: likes
    base.alias_attribute :likes, likes

    base.scope :popular, ->        { eager_load(:users).order('saved_count DESC') }
    base.scope :liked,   ->  (uid) { eager_load(:users).where(users: { id: uid }) }
    base.extend(ClassMethods)
  end

  module ClassMethods
  end
end
