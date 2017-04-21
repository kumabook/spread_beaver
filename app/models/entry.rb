# coding: utf-8
require('pink_spider')
require('paginated_array')
require('playlistified_entry')

class Entry < ApplicationRecord
  include Likable
  include Savable
  include Readable

  attr_accessor :count_of

  belongs_to :feed            , touch: true

  has_many :entry_enclosures, dependent: :destroy
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
  scope :with_content,  -> {
    preload(:tracks, :albums, :playlists)
  }
  scope :with_detail, -> {
    with_content().eager_load(:keywords)
  }
  scope :latest,        ->     (time) { where("published > ?", time).order('published DESC').with_content }
  scope :subscriptions, ->       (ss) { where(feed: ss.map { |s| s.feed_id }).order('published DESC').with_content }
  scope :feed,          ->     (feed) { where(feed: feed).order('published DESC').with_content }
  scope :feeds,         ->    (feeds) { where(feed: feeds).order('published DESC').with_content }
  scope :keyword,       ->        (k) { joins(:keywords).where(keywords: { id: k.id}).order('published DESC').with_content }
  scope :tag,           ->        (t) { joins(:tags).where(tags: { id: t.id}).order('published DESC').with_content }
  scope :topic,         ->    (topic) { feeds(topic.feeds) }
  scope :category,      -> (category) { feeds(category.subscriptions.map { |s| s.feed_id })}
  scope :issue,         ->          (j) { joins(:issues).where(issues: { id: j.id}).order('entry_issues.engagement DESC').with_content }

  JSON_ATTRS = ['content', 'categories', 'summary', 'alternate', 'origin', 'visual']
  WAITING_SEC_FOR_VISUAL = 0.5
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
    en.save
    en
  end

  def self.update_visuals(max: 50)
    self.order('published DESC').page(0).per(max)
        .where(visual: nil).find_in_batches(batch_size: 20) do |entries|

      client         = Feedlr::Client.new(sandbox: false)
      sleep(WAITING_SEC_FOR_VISUAL)
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
        visual       = feedlr_entry&.visual
        visual_url   = visual.url if visual.present?
        if !entry.has_visual? && visual_url.present? && visual_url != "none"
          logger.info("Update the visual of #{entry.url} with #{visual_url}")
          entry.visual = visual.to_json
          entry.save
        end
      end
    end
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
        tracks:    count_hashes[   Track.name][e.id],
        albums:    count_hashes[   Album.name][e.id],
        playlists: count_hashes[Playlist.name][e.id],
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

  def self.latest_items(since: 3.days.ago,
                        entries_per_feed: 3,
                        page: 1, per_page: nil)
    entries = Entry.latest(since)
    Mix::mix_up_and_paginate(entries, entries_per_feed, page, per_page)
  end

  def self.popular_items_within_period(period: nil, page: 0, per_page: PER_PAGE)
    best_items_within_period(clazz: SavedEntry,
                             period: period,
                             per_page: per_page, page: page)
  end

  def self.best_items_within_period(clazz: nil, period: nil, page: 1, per_page: PER_PAGE)
    raise ArgumentError, "Parameter must be not nil" if period.nil? || clazz.nil?
    count_hash  = clazz.period(period.begin, period.end).user_count
    total_count = count_hash.keys.count
    sorted_hashes = PaginatedArray::sort_and_paginate_count_hash(count_hash,
                                                                 page: page,
                                                                 per_page: per_page)
    entries = Entry.with_content.find(sorted_hashes.map {|h| h[:id] })
    sorted_entries = sorted_hashes.map {|h|
      entries.select { |e| e.id == h[:id] }.first
    }
    PaginatedArray.new(sorted_entries, total_count)
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

  def as_content_json(only_legacy: false)
    hash               = as_json
    hash['engagement'] = saved_count
    hash['tags']       = nil
    hash['enclosure']  = [tracks, playlists, albums].flat_map do |items|
      items.select {|item| !only_legacy || item.legacy? }
           .map { |item| item.as_enclosure }
    end

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
