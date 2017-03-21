class Enclosure < ApplicationRecord
  attr_accessor :content
  include Likable
  include Savable
  include Openable

  has_many :entry_enclosures, dependent: :destroy
  has_many :entries         , through:   :entry_enclosures

  scope :latest, -> (time) { where("created_at > ?", time).order('created_at DESC') }
  scope :detail, ->        { includes([:likers, :openers]).eager_load(:entries) }

  def self.create_items_of(entry, items)
    models = items.map do |i|
      model = find_or_create_by(id: i['id']) do
        logger.info("New enclosure #{i['provider']} #{i['identifier']}")
      end
      EntryEnclosure.find_or_create_by(entry:          entry,
                                       enclosure:      model,
                                       enclosure_type: name) do
        logger.info("Add new #{name} #{i['id']} to entry #{entry.id}")
      end
      model.content = i
      model
    end
    models
  end

  def self.fetch_content(id)
    PinkSpider.new.public_send("fetch_#{name.downcase}".to_sym, id)
  end

  def self.fetch_contents(ids)
    PinkSpider.new.public_send("fetch_#{name.downcase.pluralize}".to_sym, ids)
  end

  def self.set_contents(enclosures)
    contents = fetch_contents(enclosures.map {|t| t.id })
    enclosures.each do |e|
      e.content = contents.select {|c| c["id"] == e.id }.first
    end
  end

  def self.set_marks(user, enclosures)
    liked_hash  = Enclosure.user_liked_hash( user, enclosures)
    saved_hash  = Enclosure.user_saved_hash( user, enclosures)
    opened_hash = Enclosure.user_opened_hash(user, enclosures)
    enclosures.each do |e|
      e.is_liked  = liked_hash[e]
      e.is_saved  = saved_hash[e]
      e.is_opened = opened_hash[e]
    end
  end

  def self.marks_hash_of_user(clazz, user, enclosures)
    marks = clazz.where(user_id:      user.id,
                        enclosure_id: enclosures.map { |e| e.id })
    enclosures.inject({}) do |h, e|
      h[e] = marks.to_a.select {|l| e.id == l.enclosure_id }.first.present?
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
    if is_liked.present?
      hash['is_liked'] = is_liked
    end
    if is_saved.present?
      hash['is_saved'] = is_saved
    end
    if is_opened.present?
      hash['is_opened'] = is_opened
    end
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
