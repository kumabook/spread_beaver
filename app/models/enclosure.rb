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

  def self.my_opens_hash(user, enclosures)
    my_opens = OpenedEnclosure.where(user_id:      user.id,
                                     enclosure_id: enclosures.map { |t| t.id })
    count = OpenedEnclosure.where(enclosure_id: enclosures.map { |t| t.id })
              .group(:enclosure_id).count('enclosure_id')
    enclosures.inject({}) do |h, t|
      h[t] = {
        my: my_opens.to_a.select {|l| t.id == l.enclosure_id }.first,
        count: count.to_a.select {|c| t.id == c[0] }.map {|c| c[1] }.first,
      }
      h
    end
  end

  def self.best_items_within_period(clazz: nil, from: nil, to: nil, page: 1, per_page: nil)
    raise ArgumentError, "Parameter must be not nil" if from.nil? || to.nil?
    user_count_hash = clazz.where(enclosure_type: self.name)
                           .period(from, to).user_count
    total_count     = user_count_hash.keys.count
    start_index     = [0, page - 1].max * per_page
    end_index       = [total_count - 1, start_index + per_page - 1].min
    sorted_hashes   = user_count_hash.keys.map {|id|
      {
        id:         id,
        user_count: user_count_hash[id]
      }
    }.sort_by { |hash|
      hash[:user_count]
    }.reverse.slice(start_index..end_index)
    items = self.eager_load(:entries)
              .find(sorted_hashes.map {|h| h[:id] })
    sorted_items = sorted_hashes.map {|h|
      items.select { |t| t.id == h[:id] }.first
    }
    PaginatedArray.new(sorted_items, total_count)
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
