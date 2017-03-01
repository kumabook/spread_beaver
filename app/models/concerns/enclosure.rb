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

  def as_content_json
    hash = as_json
    hash['likesCount']   = like_count
    hash['entriesCount'] = entries_count
    hash.delete('users')
    hash
  end

  def as_detail_json
    hash = as_content_json
    hash['likers']     = [] # hash['users'] TODO
    hash['entries']    = entries.map { |e| e.as_json }
    hash
  end

  def to_query
    as_content_json.to_query
  end

  def as_enclosure
    {
      href: "typica://v3/#{self.class.table_name}/#{id}?#{to_query}",
      type: "application/json",
    }
  end

  module ClassMethods
  end
end
