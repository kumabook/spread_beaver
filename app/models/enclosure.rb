# frozen_string_literal: true
class Enclosure < ApplicationRecord
  LEGACY_PROVIDERS = ["YouTube", "SoundCloud"]
  attr_accessor :engagement
  attr_accessor :content
  attr_accessor :partial_entries
  attr_accessor :scores
  include Streamable
  include Likable
  include Savable
  include Playable
  include EnclosureEngagementScorer

  ENTRIES_LIMIT         = 100
  PARTIAL_ENTRIES_LIMIT = 100
  PICKS_LIMIT           = 100
  CONTAINERS_LIMIT      = 100

  after_create :purge_all
  after_save :purge
  after_destroy :purge, :purge_all
  after_touch :purge

  enum provider: [:Raw, :Custom, :YouTube, :SoundCloud, :Spotify, :AppleMusic]

  has_many :entry_enclosures, dependent: :destroy
  has_many :entries, ->{
    order("entries.published DESC").limit(ENTRIES_LIMIT)
  }, through: :entry_enclosures

  has_many :containers      , dependent: :destroy   , class_name: 'Pick'
  has_many :pick_containers , ->{
    order("picks.updated_at DESC").limit(CONTAINERS_LIMIT)
  }, through: :containers, source: :container

  has_many :picks           , dependent: :destroy, foreign_key: "container_id"
  has_many :pick_enclosures , ->{
    order("picks.updated_at DESC").limit(PICKS_LIMIT)
  }, through: :picks, source: :enclosure

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

  scope :with_content, -> { eager_load(:entry_enclosures).eager_load(:entries) }
  scope :with_detail, -> {
    eager_load(:entries)
      .eager_load(:pick_containers)
      .eager_load(:pick_enclosures)
  }

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

  def has_thumbnail?
    content.present? && content['thumbnail_url'].present?
  end

  def thumbnail_url
    content['thumbnail_url']
  end

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
    find_or_create_by_content(c)
  end

  def fetch_content
    @content = PinkSpider.new.public_send("fetch_#{self.class.name.downcase}".to_sym, id)
    @content
  end

  def update_content(params)
    PinkSpider.new.public_send("update_#{self.class.name.downcase}".to_sym, id, params)
  end

  def self.fetch_contents(ids)
    PinkSpider.new.public_send("fetch_#{name.downcase.pluralize}".to_sym, ids)
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

  def self.most_featured_items(stream: nil, query: {}, page: 1, per_page: 10)
    # doesn't support locale, use stream filter instead
    count_hash = self.query_for_best_items(EntryEnclosure, stream, query.no_locale).feed_count
    Mix.items_from_count_hash(self, count_hash, page: page, per_page: per_page)
  end

  def self.most_picked_items(stream: nil, query: {}, page: 1, per_page: 10)
    # doesn't support locale, use stream filter instead
    count_hash = self.query_for_best_items(Pick, stream, query.no_locale).pick_count
    Mix.items_from_count_hash(self, count_hash, page: page, per_page: per_page)
  end

  def self.query_for_best_items(clazz, stream, query=nil)
    clazz.where(enclosure_type: self.name)
      .stream(stream)
      .period(query.period)
      .locale(query.locale)
      .provider(query.provider)
  end

  def legacy?
    type == Track.name && @content && LEGACY_PROVIDERS.include?(@content['provider'])
  end

  def as_content_json
    hash = as_json
    hash['likesCount']   = likes_count
    hash['entriesCount'] = entries_count
    hash['pickCount']    = pick_count
    hash.delete('users')
    [:is_liked, :is_saved, :is_played, :engagement].each do |method|
      v = self.public_send(method)
      hash[method.to_s] = v if !v.nil?
    end

    if !@content.nil?
      hash.merge! @content
    end

    if !@partial_entries.nil?
      hash['entries'] = @partial_entries.map { |e| e.as_partial_json }
    end
    hash
  end

  def as_detail_json
    hash = as_content_json
    hash['entries'] = entries.map(&:as_partial_json) if hash['entries'].nil?
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
