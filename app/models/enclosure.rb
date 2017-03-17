class Enclosure < ApplicationRecord
  attr_accessor :content
  include Likable
  include Savable
  include Openable

  has_many :entry_enclosures, dependent: :destroy
  has_many :entries         , through:   :entry_enclosures

  scope :latest, -> (time) { where("created_at > ?", time).order('created_at DESC') }
  scope :detail, ->        { eager_load(:users).eager_load(:entries) }


  def self.my_likes_hash(user, enclosures)
    my_likes = LikedEnclosure.where(user_id:      user.id,
                                    enclosure_id: enclosures.map { |t| t.id })
    count = LikedEnclosure.where(enclosure_id: enclosures.map { |t| t.id })
              .group(:enclosure_id).count('enclosure_id')
    enclosures.inject({}) do |h, t|
      h[t] = {
        my: my_likes.to_a.select {|l| t.id == l.enclosure_id }.first,
        count: count.to_a.select {|c| t.id == c[0] }.map {|c| c[1] }.first,
      }
      h
    end
  end

  def self.my_saves_hash(user, enclosures)
    my_saves = SavedEnclosure.where(user_id:      user.id,
                                    enclosure_id: enclosures.map { |t| t.id })
    count = SavedEnclosure.where(enclosure_id: enclosures.map { |t| t.id })
              .group(:enclosure_id).count('enclosure_id')
    enclosures.inject({}) do |h, t|
      h[t] = {
        my: my_saves.to_a.select {|l| t.id == l.enclosure_id }.first,
        count: count.to_a.select {|c| t.id == c[0] }.map {|c| c[1] }.first,
      }
      h
    end
  end

  def as_content_json
    hash = as_json
    hash['likesCount']   = likes_count
    hash['entriesCount'] = entries_count
    hash.delete('users')
    hash.merge! @content if !@content.nil?
    hash['id'] = id
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
      href: "typica://v3/#{self.class.name.downcase.pluralize}/#{id}?#{to_query}",
      type: "application/json",
    }
  end
end
