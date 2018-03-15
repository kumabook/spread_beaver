class Enclosure < ApplicationRecord
  LEGACY_PROVIDERS = ["YouTube", "SoundCloud"]
  attr_accessor :content
  attr_accessor :partial_entries
  include Likable
  include Savable
  include Playable

  ENTRIES_LIMIT = 100
  PARTIAL_ENTRIES_LIMIT = 100

  after_create :purge_all
  after_save :purge
  after_destroy :purge, :purge_all
  after_touch :purge

  enum provider: [:Raw, :Custom, :YouTube, :SoundCloud, :Spotify, :AppleMusic]

  has_many :entry_enclosures, dependent: :destroy
  has_many :entries, ->{ order("entries.published DESC").limit(ENTRIES_LIMIT) }, through: :entry_enclosures

  has_many :enclosure_issues, dependent: :destroy
  has_many :issues          , through: :enclosure_issues

  scope :provider, -> (provider) {
    where(provider: provider) if provider.present?
  }
  scope :latest, -> (since) {
    if since.nil?
      order(created_at: :desc)
    else
      where(created_at: since..Float::INFINITY).order(created_at: :desc)
    end
  }
  scope :detail, ->        { includes([:likers]).includes(:entries) }
  scope :issue , -> (issue) {
    joins(:enclosure_issues)
      .where(enclosure_issues: { issue: issue })
      .order("enclosure_issues.engagement DESC")
  }
  scope :feed, -> (feed) {
    joins(:entries).where(entries: { feed_id: feed.id })
  }
  scope :keyword, -> (keyword) {
    joins(entries: :keywords).where(keywords: { id: keyword.id })
  }
  scope :tag, -> (tag) {
    joins(entries: :tags).where(tags: { id: tag.id })
  }
  scope :topic, -> (topic) {
    joins(entries: {feed: :topics }).where(topics: { id: topic.id })
  }
  scope :category, -> (category) {
    joins(entries: {feed: { subscriptions: :categories }})
      .where(categories: { id: category.id })
  }
  scope :period, -> (period) {
    where({ table_name.to_sym => { created_at:  period }})
  }
  scope :stream, -> (s) {
    if s.kind_of?(Feed)
      feed(s)
    elsif s.kind_of?(Keyword)
      keyword(s)
    elsif s.kind_of?(Tag)
      tag(s)
    elsif s.kind_of?(Topic)
      topic(s)
    elsif s.kind_of?(Category)
      category(s)
    elsif s.kind_of?(Issue)
      issue(s)
    else
      raise Exception.new("Unknown stream")
    end
  }

  def self.find_or_create_by_content(content)
    model = find_or_create_by(id: content['id']) do |m|
      m.created_at = content["published_at"]
      m.title      = content["title"]
      m.provider   = content["provider"]
    end
    model.content = content
    model
  end

  def self.create_items_of(entry, items)
    models = items.map do |i|
      model = find_or_create_by_content(i)
      EntryEnclosure.find_or_create_by(entry_id:           entry.id,
                                       enclosure_id:       model.id,
                                       enclosure_type:     name,
                                       enclosure_provider: model.provider) do
        logger.info("Add new #{name} #{i['id']} to entry #{entry.id} #{i["provider"]}")
      end
      model
    end
    models
  end

  def self.create_with_pink_spider(params)
    c = PinkSpider.new.public_send("create_#{name.downcase}".to_sym, params)
    item = find_or_create_by(id: c["id"]) do
      logger.info("New enclosure #{c['provider']} #{c['identifier']}")
    end
    item.update(created_at: c["published_at"])
    item.content = c
    item
  end

  def self.fetch_content(id)
    PinkSpider.new.public_send("fetch_#{name.downcase}".to_sym, id)
  end

  def self.fetch_contents(ids)
    PinkSpider.new.public_send("fetch_#{name.downcase.pluralize}".to_sym, ids)
  end

  def self.update_content(id, params)
    PinkSpider.new.public_send("update_#{name.downcase}".to_sym, id, params)
  end

  def self.search(query, page, per_page)
    req_page = page.nil? ? 0 : page.to_i - 1
    res = PinkSpider.new.public_send("search_#{name.downcase.pluralize}".to_sym,
                                     query,
                                     req_page,
                                     per_page)
    contents = res['items']
    enclosures = self.where(id: contents.map {|content| content["id"] }).each do |e|
      e.content = contents.select {|c| c["id"] == e.id }.first
    end
    PaginatedArray.new(enclosures, res['total'], res['page'] + 1, res['per_page'])
  end

  def self.set_contents(enclosures)
    return enclosures if enclosures.blank?
    contents = fetch_contents(enclosures.map {|t| t.id })
    enclosures.each do |e|
      e.content = contents.select {|c| c["id"] == e.id }.first
    end
    enclosures
  end

  def self.set_partial_entries(enclosures)
    items = EntryEnclosure.where(enclosure_id: enclosures.map {|e| e.id })
                          .order('entries.published DESC')
                          .joins(:entry)
                          .limit(PARTIAL_ENTRIES_LIMIT)
                          .preload(:entry)
    enclosures.each do |e|
      e.partial_entries = items.select {|item| item.enclosure_id == e.id }
                               .map {|item| item.entry }
    end
  end

  def self.set_marks(user, enclosures)
    liked_hash  = Enclosure.user_liked_hash( user, enclosures)
    saved_hash  = Enclosure.user_saved_hash( user, enclosures)
    played_hash = Enclosure.user_played_hash(user, enclosures)
    enclosures.each do |e|
      e.is_liked  = liked_hash[e]
      e.is_saved  = saved_hash[e]
      e.is_played = played_hash[e]
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

  def self.most_featured_items(stream: nil,
                               period: nil,
                               locale: nil,
                               provider: nil,
                               page: 1,
                               per_page: 10)
    best_items(clazz:        EntryEnclosure,
               count_method: :feed_count,
               stream:       stream,
               period:       period,
               locale:       nil,
               provider:     provider,
               page:         page,
               per_page:     per_page)
  end

  def self.most_picked_items(stream: nil,
                             period: nil,
                             locale: nil,
                             provider: nil,
                             page: 1,
                             per_page: 10)
    best_items(clazz:        Pick,
               count_method: :pick_count,
               stream:       stream,
               period:       period,
               locale:       nil,
               provider:     provider,
               page:         page,
               per_page:     per_page)
  end

  def self.best_items(clazz: nil,
                      count_method: :user_count,
                      stream: nil,
                      period: nil,
                      locale: nil,
                      provider: nil,
                      page: 1,
                      per_page: nil)
    raise ArgumentError, "Parameter must be not nil" if period.nil?
    query = clazz.where(enclosure_type: self.name)
                 .period(period)
                 .locale(locale)
                 .provider(provider)
    query = query.stream(stream) if stream.present?
    count_hash    = query.public_send(count_method)
    total_count   = count_hash.keys.count
    sorted_hashes = PaginatedArray::sort_and_paginate_count_hash(count_hash,
                                                                 page: page,
                                                                 per_page: per_page)
    items = self.eager_load(:entry_enclosures)
                .eager_load(:entries)
                .find(sorted_hashes.map {|h| h[:id] })
    sorted_items = sorted_hashes.map {|h|
      items.select { |t| t.id == h[:id] }.first
    }
    PaginatedArray.new(sorted_items, total_count)
  end

  def legacy?
    type == Track.name && @content && LEGACY_PROVIDERS.include?(@content['provider'])
  end

  def as_content_json
    hash = as_json
    hash['likesCount']   = likes_count
    hash['entriesCount'] = entries_count
    hash.delete('users')
    if !is_liked.nil?
      hash['is_liked'] = is_liked
    end
    if !is_saved.nil?
      hash['is_saved'] = is_saved
    end
    if !is_played.nil?
      hash['is_played'] = is_played
    end

    if !@content.nil?
      hash.merge! @content
    end

    if !@partial_entries.nil?
      hash['entries'] = @partial_entries.map { |e| e.as_partial_json }
    end

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
