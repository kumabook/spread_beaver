# coding: utf-8
require('pink_spider')
require('paginated_array')
require('playlistified_entry')

class Entry < ApplicationRecord
  include Streamable
  include Likable
  include Savable
  include Readable

  attr_accessor :count_of

  belongs_to :feed            , touch: true

  order_by_engagement = ->{order("entry_enclosures.engagement DESC") }

  has_many :entry_enclosures, order_by_engagement, dependent: :destroy
  has_many :entry_tags      , dependent: :destroy
  has_many :entry_keywords  , dependent: :destroy
  has_many :entry_issues    , dependent: :destroy
  has_many :keywords        , through: :entry_keywords
  has_many :tags            , through: :entry_tags
  has_many :issues          , through: :entry_issues
  has_many :tracks          , through: :entry_enclosures, source: :enclosure, source_type: Track.name
  has_many :albums          , through: :entry_enclosures, source: :enclosure, source_type: Album.name
  has_many :playlists       , through: :entry_enclosures, source: :enclosure, source_type: Playlist.name


  self.primary_key = :id

  before_save :normalize_visual
  after_create :purge_all
  after_save :purge
  after_destroy :purge, :purge_all
  after_touch :purge

  scope :with_content,  -> {
    preload(:tracks, :albums, :playlists)
  }
  scope :with_detail, -> {
    with_content().eager_load(:keywords)
  }
  scope :latest,        ->    (since) {
    if since.nil?
      order(published: :desc).with_content
    else
      where(published: since..Float::INFINITY).order(published: :desc).with_content
    end
  }
  scope :subscriptions, ->       (ss) { where(feed: ss.map { |s| s.feed_id }).order(published: :desc).with_content }
  scope :feed,          ->     (feed) { where(feed: feed).order(published: :desc).with_content }
  scope :keyword,       ->        (k) { joins(:entry_keywords).where(entry_keywords: { keyword_id: k.id}).order(published: :desc).with_content }
  scope :tag,           ->        (t) { joins(:tags).where(tags: { id: t.id}).order(published: :desc).with_content }
  scope :topic,         ->    (topic) { joins(feed: :topics).where(topics: { id: topic.id }) }
  scope :category,      -> (category) { joins(feed: { subscriptions: :categories }).where(categories: { id: category.id })}
  scope :issue,         ->          (j) { joins(:issues).where(issues: { id: j.id}).order('entry_issues.engagement DESC').with_content }
  scope :period, -> (period) {
    where({ table_name.to_sym => { published:  period }})
  }
  scope :search, -> (query) {
    if query.present?
      where("title ILIKE ?", "%#{query}%")
    else
      all
    end
  }

  JSON_ATTRS = ['content', 'categories', 'summary', 'alternate', 'origin', 'visual']
  PER_PAGE = Kaminari::config::default_per_page

  def entry_enclosure_type=(class_name)
    super(class_name.constantize.base_class.to_s)
  end

  def self.first_or_create_by_feedlr(entry, feed)
    en = Entry.find_or_create_by(id: entry.id) do |e|
      e.title       = entry.title
      e.content     = entry.content.to_json
      e.summary     = entry.summary.to_json
      e.author      = entry.author

      e.alternate   = entry.alternate.to_json
      e.origin      = entry.origin.to_json
      e.visual      = entry.visual.to_json

      e.engagement  = entry.engagement
      e.enclosure   = entry.enclosure.to_json
      e.fingerprint = entry.fingerprint
      e.originId    = entry.originId

      e.crawled     = entry.crawled.to_time
      e.published   = entry.published.to_time
      e.recrawled   = entry.recrawled&.to_time
      e.updated     = entry.updated&.to_time
      e.feed        = feed
      if entry.keywords.present?
        e.keywords  = entry.keywords.uniq.map { |k| Keyword.find_or_create_by label: k }
      end
    end
    en.save
    en
  end

  def self.first_or_create_by_pink_spider(entry, feed)
    en = Entry.find_or_create_by(id: entry["id"]) do |e|
      e.title       = entry["title"]
      e.content     = { "content": entry["content"] }.to_json
      e.summary     = { "content": entry["summary"] }.to_json
      e.author      = entry["author"]

      e.alternate   = entry["alternate"].to_json
      e.origin      = {
        htmlUrl:  feed.website,
        streamId: feed.id,
        title:    feed.title,
      }.to_json
      e.visual      = {
        url: entry["visual_url"],
        processor: "pink-spider-v1"
      }.to_json

      e.engagement  = 0
      e.enclosure   = entry["enclosure"].to_json
      e.fingerprint = entry["fingerprint"]
      e.originId    = entry["origin_id"]

      e.crawled     = DateTime.parse(entry["crawled"])
      e.published   = DateTime.parse(entry["published"])
      e.recrawled   = entry["recrawled"].present? ? DateTime.parse(entry["recrawled"]) : nil
      e.updated     = entry["updated"].present?   ? DateTime.parse(entry["updated"]) : nil
      e.feed        = feed
      if entry["keywords"].present?
        e.keywords  = entry["keywords"].uniq.map { |k| Keyword.find_or_create_by label: k }
      end
    end
    en.save
    en
  end

  def self.find_or_create_dummy_for_feed(feed)
    id = Digest::MD5.hexdigest(feed.id)
    entry = Entry.find_or_create_by(id: id) do |e|
      e.title       =  "dummy for #{feed.id}"
      e.engagement  = -1
      e.fingerprint = ""
      e.originId    = id
    end
    entry.feed = feed
    entry.save
    entry
  end

  def self.crawl(period: 1.month.ago..Time.now)
    Entry.where("created_at >= ?", period.begin)
         .where("created_at <= ?", period.end).find_each do |entry|
      entry.crawl(force: true)
    end
  end

  def crawl(force: false)
    begin
      playlistified_entry = playlistify(force: force)
    rescue
      Rails.logger.info("Entry #{id} no longer exist")
      return
    end
    if playlistified_entry.visual_url.present?
      self.visual = {
        url: playlistified_entry.visual_url,
        processor: "pink-spider-v1"
      }.to_json
    end
    new_tracks    = Track.create_items_of(self, playlistified_entry.tracks)
    new_playlists = Playlist.create_items_of(self, playlistified_entry.playlists)
    new_albums    = Album.create_items_of(self, playlistified_entry.albums)

    new_playlists.each do |playlist|
      playlist.fetch_tracks
    end

    self.save
    {
      tracks:    new_tracks,
      playlists: new_playlists,
      albums:    new_albums,
    }
  end

  def self.set_marks(user, entries)
    liked_hash  = Entry.user_liked_hash(user, entries)
    saved_hash  = Entry.user_saved_hash(user, entries)
    read_hash   = Entry.user_read_hash( user, entries)
    entries.each do |e|
      e.is_liked  = liked_hash[e]
      e.is_saved  = saved_hash[e]
      e.unread    = !read_hash[e]
    end
  end

  def self.marks_hash_of_user(clazz, user, entries)
    marks = clazz.where(user_id:  user.id,
                        entry_id: entries.map { |e| e.id })
    entries.inject({}) do |h, e|
      h[e] = marks.to_a.select {|l| e.id == l.entry_id }.first.present?
      h
    end
  end


  def self.set_count_of_enclosures(entries)
    count_hashes = [Track.name, Album.name, Playlist.name].inject({}) do |hash, type|
      hash[type] = EntryEnclosure.where(entry_id:       entries.map {|e| e.id},
                                        enclosure_type: type).enclosure_count
      hash
    end
    entries.each do |e|
      e.count_of = {
        tracks:    count_hashes[   Track.name][e.id] || 0,
        albums:    count_hashes[   Album.name][e.id] || 0,
        playlists: count_hashes[Playlist.name][e.id] || 0,
      }
    end
  end

  def self.set_contents_of_enclosures(entries)
    track_items    = entries.flat_map {|e| e.tracks }
    album_items    = entries.flat_map {|e| e.albums }
    playlist_items = entries.flat_map {|e| e.playlists }
    {
      tracks:    Track.set_contents(track_items),
      albums:    Album.set_contents(album_items),
      playlists: Playlist.set_contents(playlist_items),
    }
  end

  def self.enclosures_of_entries(entries)
    entries.flat_map {|e| [e.tracks, e.albums, e.playlists].flatten }
  end

  def self.set_partial_entries_of_enclosures(entries)
    enclosures = self.enclosures_of_entries(entries)
    Enclosure.set_partial_entries(enclosures)
  end

  def self.set_marks_of_enclosures(user, entries)
    enclosures = enclosures_of_entries(entries)
    Enclosure.set_marks(user, enclosures)
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
      logger.info("Clear the visual of #{self.url}")
      self.visual = nil
    end
  end

  def origin_hash
    JSON.load(self.origin)
  end

  def has_visual?
    visual_url.present? && visual_url != 'none'
  end

  alias has_thumbnail? has_visual?
  alias thumbnail_url visual_url

  def self.latest_items(since: 3.days.ago,
                        entries_per_feed: 3,
                        page: 1, per_page: nil)
    entries = Entry.latest(since)
    Mix::mix_up_and_paginate(entries, entries_per_feed, page, per_page)
  end
  def self.query_for_best_items(clazz, stream, query={})
    clazz.stream(stream).period(query.period).locale(query.locale)
  end

  def playlistify(force: false)
    hash = PinkSpider.new.playlistify url: url, force: force
    return if hash.nil?
    PlaylistifiedEntry.new(hash['id'],
                           hash['url'],
                           hash['title'],
                           hash['description'],
                           hash['visual_url'],
                           hash['locale'],
                           hash['tracks'],
                           hash['playlists'],
                           hash['albums'],
                           self)
  end

  def as_partial_json()
    as_json(except: ['content', 'summary'])
  end

  def as_json(options = {})
    h               = super(options)
    h['crawled']    = crawled&.to_time.to_i * 1000
    h['published']  = published&.to_time.to_i * 1000
    h['recrawled']  = recrawled&.to_time&.to_i&.* 1000
    h['updated']    = updated&.to_time&.to_i&.* 1000
    h['categories'] = []
    h['keywords']   = nil
    h['origin']     ||= {}
    h.delete('saved_count')

    JSON_ATTRS.each do |key|
      h[key] = JSON.load(h[key]) if h[key].present?
    end
    h
  end

  def as_content_json(only_legacy: false, enclosure_as_json: :as_content_json)
    hash               = as_json
    hash['engagement'] = saved_count
    hash['tags']       = nil
    hash['enclosure']  = [tracks, playlists, albums].flat_map do |items|
      items.select {|item| !only_legacy || item.legacy? }
           .map { |item| item.as_enclosure }
    end

    hash['tracks']    = tracks.map(&enclosure_as_json)
    hash['playlists'] = playlists.map(&enclosure_as_json)
    hash['albums']    = albums.map(&enclosure_as_json)

    if !is_liked.nil?
      hash['is_liked'] = is_liked
    end
    if !is_saved.nil?
      hash['is_saved'] = is_saved
    end
    if !is_read.nil?
      hash['unread'] = !is_read
    end
    if !likes_count.nil?
      hash['likes_count'] = likes_count
    end
    if !saved_count.nil?
      hash['saved_count'] = saved_count
    end
    if !read_count.nil?
      hash['read_count'] = read_count
    end

    hash
  end

  def as_detail_json
    hash             = as_content_json
    hash['tags']     = []
    hash['keywords'] = keywords.map { |k| k.label }
    hash
  end
end
