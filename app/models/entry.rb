# coding: utf-8
class Entry < ActiveRecord::Base
  belongs_to :feed
  has_many :entry_tracks
  has_many :saved_entries
  has_many :read_entries
  has_many :entry_tags
  has_many :entry_keywords
  has_many :keywords   , through: :entry_keywords
  has_many :tags       , through: :entry_tags
  has_many :saved_users, through: :saved_entries, source: :user
  has_many :readers    , through: :read_entries,  source: :user
  has_many :tracks     , through: :entry_tracks
  self.primary_key = :id

  before_save :normalize_visual

  scope :with_content,  ->            { includes(:tracks) }
  scope :with_detail,   ->            { includes(:saved_users).includes(:tracks).includes(:keywords) }
  scope :latest,        ->     (time) { where("published > ?", time).order('published DESC').with_content }
  scope :popular,       ->            { joins(:saved_users).order('saved_count DESC').with_content }
  scope :subscriptions, ->       (ss) { where(feed: ss.map { |s| s.feed_id }).order('published DESC').with_content }
  scope :feed,          ->     (feed) { where(feed: feed).order('published DESC').with_content }
  scope :feeds,         ->    (feeds) { where(feed: feeds).order('published DESC').with_content }
  scope :keyword,       ->        (k) { joins(:keywords).where(keywords: { id: k.id}).order('published DESC').with_content }
  scope :tag,           ->        (t) { joins(:tags).where(tags: { id: t.id}).order('published DESC').with_content }
  scope :topic,         ->    (topic) { feeds(topic.feeds) }
  scope :category,      -> (category) { feeds(category.subscriptions.map { |s| s.feed_id })}
  scope :saved,         ->     (user) { joins(:saved_entries).includes(:tracks).where(saved_entries: { user_id: user.id }) }
  scope :read,          ->     (user) { joins(:read_entries).includes(:tracks).where(read_entries: { user_id: user.id }) }

  JSON_ATTRS = ['content', 'categories', 'summary', 'alternate', 'origin', 'visual']

  def self.first_or_create_by_feedlr(entry, feed)
    e = Entry.find_or_create_by(id: entry.id) do |e|
      e.title       = entry.title
      e.content     = entry.content.to_json
      e.summary     = entry.summary.to_json
      e.author      = entry.author

      e.alternate   = entry.alternate.to_json
      e.origin      = entry.origin.to_json
      e.visual      = entry.visual.to_json
      e.categories  = entry.categories.to_json
      e.unread      = entry.unread

      e.engagement  = entry.engagement
      e.actionTimestamp = entry.actionTimestamp
      e.enclosure   = entry.enclosure.to_json
      e.fingerprint = entry.fingerprint
      e.originId    = entry.originId
      e.sid         = entry.sid

      e.crawled     = Time.at(entry.crawled / 1000)
      e.published   = Time.at(entry.published / 1000)
      e.recrawled   = entry.recrawled.present? ? Time.at(entry.recrawled / 1000) : nil
      e.updated     = entry.updated.present?   ? Time.at(entry.updated / 1000) : nil
      e.feed        = feed
      if entry.keywords.present?
        e.keywords  = entry.keywords.uniq.map { |k| Keyword.find_or_create_by label: k }
      end
    end
    e.save
    e
  end

  def self.update_visuals(max: 50)
    self.order('published DESC').page(0).per(max)
        .where(visual: nil).find_in_batches(batch_size: 20) do |entries|

      client         = Feedlr::Client.new(sandbox: false)
      sleep(0.1)
      feedlr_entries = client.user_entries(entries.map { |e| e.id })
      hash = entries.reduce({}) do |h, e|
        h[e.id] = {} if h[e.id].nil?
        h[e.id][:entry] = e
        h
      end
      feedlr_entries.reduce(hash) do |h, e|
        h[e.id][:feedlr_entry] = e
        h
      end
      hash.each do |id, value|
        entry        = value[:entry]
        feedlr_entry = value[:feedlr_entry]
        visual       = feedlr_entry.visual
        visual_url   = visual.url if visual.present?
        if !entry.has_visual? && visual_url.present? && visual_url != "none"
          puts "Update the visual of #{entry.url} with #{visual_url}"
          entry.visual = visual.to_json
          entry.save
        end
      end
    end
  end

  def url
    items = JSON.load(alternate)
    items.present? && items[0]['href']
  end

  def visual_url
    visual = JSON.load(self.visual)
    if visual.present? && visual['url'].present?
      visual['url']
    else
      nil
    end
  end

  def normalize_visual
    return if self.visual.nil?
    v = JSON.load(self.visual)
    if v.blank? || v['url'].blank? || v['url'] == "none"
      puts "Clear the visual of #{self.url}"
      self.visual = nil
    end
  end

  def origin_hash
    JSON.load(self.origin)
  end

  def has_visual?
    visual_url.present? && visual_url != 'none'
  end

  def self.latest_entries(since: 3.days.ago, entries_per_feed: 3)
    # TODO: Add page and per_page if need be
    entries = Entry.latest(since)
    sort_one_by_one_by_feed(entries, entries_per_feed: entries_per_feed)
  end

  def self.latest_entries_of_topic(topic, since: 3.days.ago, entries_per_feed: 3)
    # TODO: Add page and per_page if need be
    entries = Entry.topic(topic).latest(since)
    sort_one_by_one_by_feed(entries, entries_per_feed: entries_per_feed)
  end

  def self.sort_one_by_one_by_feed(entries, entries_per_feed: 3)
    entries_list = entries.map { |entry| entry.feed_id }
                   .uniq
                   .map do |id|
      entries.select { |e| e.feed_id == id }.first(entries_per_feed)
    end

    (0...entries_per_feed).to_a
      .flat_map { |i| entries_list.map { |list| list[i] }}
      .select   { |a| a.present? }
  end

  def self.popular_entries_within_period(from: nil, to: nil)
    best_entries_within_period(from: from, to: to, clazz: SavedEntry)
  end

  def self.hot_entries_within_period(from: nil, to: nil)
    best_entries_within_period(from: from, to: to, clazz: ReadEntry)
  end

  def self.best_entries_within_period(from: nil, to: nil, clazz: nil)
    raise ArgumentError, "Parameter must be not nil" if from.nil? || to.nil? || clazz.nil?
    # TODO: Add page and per_page if need be
    user_count_hash = clazz.period(from, to).user_count
    entries = Entry.with_content.find(user_count_hash.keys)
    # order by user_count and updated
    user_count_hash.keys.map { |id|
      {
                id: id,
        user_count: user_count_hash[id],
             entry: entries.select { |e| e.id == id }.first
      }
    }.sort_by { |hash|
      [hash[:user_count], [hash[:entry].updated_at]]
    }.reverse.map { |hash| hash[:entry] }
  end

  def fetch_playlist(force: false)
    api_url = "http://pink-spider.herokuapp.com/playlistify"
    params  = { url: url, force: force}
    response = RestClient.get api_url, params: params, :accept => :json
    return if response.code != 200
    hash = JSON.parse(response)
    Playlist.new(hash['id'],
                 hash['url'],
                 hash['title'],
                 hash['description'],
                 hash['visual_url'],
                 hash['locale'],
                 hash['tracks'], self)
  end

  def as_json(options = {})
    h               = super(options)
    h['crawled']    = crawled.to_time.to_i * 1000
    h['published']  = published.to_time.to_i * 1000
    h['recrawled']  = recrawled.present? ? recrawled.to_time.to_i * 1000 : nil
    h['updated']    = updated.present?   ? updated.to_time.to_i   * 1000 : nil
    h['categories'] = []
    h['keywords']   = nil
    h.delete('saved_count')
    JSON_ATTRS.each do |key|
      h[key] = JSON.load(h[key])
    end
    h
  end

  def as_content_json
    hash               = as_json
    hash['engagement'] = saved_count
    hash['tags']       = nil
    hash['enclosure']  = tracks.map { |t| t.as_enclosure }
    hash
  end

  def as_detail_json
    hash             = as_content_json
    hash['tags']     = saved_users.map  { |u| u.as_user_tag }
    hash['keywords'] = keywords.map { |k| k.label }
    hash
  end
end
