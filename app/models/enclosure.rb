class Enclosure < ApplicationRecord
  attr_accessor :detail
  include Likable
  has_many :entry_enclosures, dependent: :destroy
  has_many :entries         , through:   :entry_enclosures

  scope :latest, -> (time) { where("created_at > ?", time).order('created_at DESC') }
  scope :detail, ->        { eager_load(:users).eager_load(:entries) }

  def as_content_json
    hash = as_json
    hash['likesCount']   = likes_count
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
end