class Feed < ApplicationRecord
  include Escapable
  include Stream
  after_touch   :touch_topics
  after_save    :delete_cache_of_search_results
  after_destroy :delete_cache_of_search_results

  has_many :entries
  has_many :feed_topics,   dependent: :destroy
  has_many :topics     ,   through:   :feed_topics
  has_many :subscriptions, dependent: :destroy

  self.primary_key = :id

  WAITING_SEC_FOR_FEED = 0.25

  scope :search, -> (query) {
    q = search_query(query)
    case q[:type]
    when :all
      eager_load(:topics).all
    when :topic
      joins(:topics).where(topics: { label: q[:value]})
    when :url
      eager_load(:topics).where(website: q[:value])
    when :title
      eager_load(:topics).where(arel_table[:title].matches("%#{q[:value]}%"))
    else
      eager_load(:topics).all
    end
  }

  scope :locale, -> (locale) {
    where(language: locale) if locale.present?
  }


  def entries_of_stream(page: 1, per_page: nil, since: nil)
    Entry.page(page).per(per_page).feed(self)
  end

  def self.delete_cache_of_search_results
    Rails.cache.delete_matched("feeds_of_search_by-*")
  end

  def delete_cache_of_search_results
    Feed.delete_cache_of_search_results
  end

  def self.search_by(query: '', locale: 'ja', page: 1, per_page: 15)
    key = "feeds_of_search_by-page(#{page})-page_page(#{per_page})-#{query}-#{locale}"
    Rails.cache.fetch(key) do
      Feed.page(page)
          .per(per_page)
          .search(query)
          .locale(locale)
          .includes([:feed_topics])
          .order('velocity DESC').to_a
    end
  end

  def self.first_or_create_by_feedlr(feed)
    Feed.find_or_create_by(id: feed.id) do |f|
      f.title       = feed.title
      f.description = feed.description || ''
      f.website     = feed.website
      f.visualUrl   = feed.visualUrl
      f.coverUrl    = feed.coverUrl
      f.iconUrl     = feed.iconUrl
      f.language    = feed.language
      f.partial     = feed.partial
      f.coverColor  = feed.coverColor
      f.contentType = feed.contentType
      f.subscribers = feed.subscribers
      f.velocity    = feed.velocity

      if feed.topics.present?
        f.topics = feed.topics.map {|t| Topic.find_or_create_by(label: t) }
      end

=begin
      f.facebookLikes     = feed.facebookLikes,
      f.facebookUsername  = feed.facebookUsername,
      f.feedId            = feed.feedId,
      f.twitterFollowers  = feed.twitterFollowers,
      f.twitterScreenName = feed.twitterScreenName,
=end
    end
  end

  def self.find_or_create_with_ids(feed_ids)
    client = Feedlr::Client.new(sandbox: false)
    feeds = client.feeds(feed_ids)
    return [] if feeds.nil?
    feeds.map do |feed|
      Feed.first_or_create_by_feedlr(feed)
    end
  end

  def self.fetch_all_latest_entries
    feeds = Feed.all
    Feed.update_visuals(feeds)
    feeds.map do |f|
      sleep(WAITING_SEC_FOR_FEED)
      f.fetch_latest_entries
    end
  end

  def self.update_visuals(feeds)
    client = Feedlr::Client.new
    feedlr_feeds = client.feeds(feeds.map { |f| f.id })
    return [] if feedlr_feeds.nil?
    feedlr_feeds.map do |feedlr_feed|
      feeds.select { |f| f.id == feedlr_feed.id }.each do |feed|
        feed.update_visuals_with_feedlr(feedlr_feed)
      end
    end
  end

  def update_visuals_with_feedlr(feed, force=false)
    ["visualUrl", "coverUrl", "iconUrl"].each do |url_method|
      url = feed.public_send(url_method)
      if url.present? && (self.public_send(url_method.to_sym).blank? || force)
        logger.info("Update #{url_method} of #{feed.id}: #{url}")
        self.public_send("#{url_method}=".to_sym, feed.visualUrl)
      end
    end
    save
  end

  def fetch_latest_entries
    new_entries   = []
    new_tracks    = []
    new_playlists = []
    new_albums    = []
    client = Feedlr::Client.new(sandbox: false)
    logger.info("Fetch latest entries of #{id}")
    newer_than = crawled.present? ? crawled.to_time.to_i : nil
    cursor = client.stream_entries_contents(id, newerThan: newer_than)

    if cursor.items.nil?
      return {
        feed:      self,
        entries:   [],
        tracks:    [],
        playlists: [],
        albums:    [],
      }
    end

    cursor.items.each do |entry|
      begin
        sleep(WAITING_SEC_FOR_FEED)
        e = Entry.first_or_create_by_feedlr(entry, self)
        logger.info("Fetch tracks of #{e.url}")
        playtified_entry = e.playlistify
        [{
           type:      'track',
           items:     Track.create_items_of(e, playtified_entry.tracks),
           new_items: new_tracks
         }, {
           type:      'playlist',
           items:     Playlist.create_items_of(e, playtified_entry.playlists),
           new_items: new_playlists
         }, {
           type:      'album',
           items:     Album.create_items_of(e, playtified_entry.albums),
           new_items: new_albums
         }].each do |hash|
          hash[:items].each do |item|
            logger.info("  Create #{hash[:type]} #{item.content['provider']} #{item.content['title']}")
            hash[:new_items] << item
          end
        end
        if playtified_entry.visual_url.present?
          e.visual = {
            url: playtified_entry.visual_url,
            processor: "pink-spider-v1"
          }.to_json
        end
        e.save
        new_entries << e
        logger.info("Update entry visual with #{playtified_entry.visual_url}")
        if self.lastUpdated.nil? || self.lastUpdated < e.published
          self.lastUpdated = e.published
        end
      rescue => err
        logger.error("Failed to fetch #{e.url}  #{err}")
        logger.error(err.backtrace)
      end
    end
    self.crawled = DateTime.now
    save
    {
      feed:      self,
      entries:   new_entries,
      tracks:    new_tracks,
      playlists: new_playlists,
      albums:    new_albums,
    }
  end

  def as_json(options = {})
    h                = super(options)
    h['lastUpdated'] = lastUpdated.present? ? lastUpdated.to_time.to_i * 1000 : nil
    h['topics']      = topics.map { |topic| topic.label }
    h
  end

  def self.search_query(query)
    if query.blank?
      return { type: :all }
    elsif query.start_with? "#"
      return { type: :topic, value: query[1..-1] }
    elsif is_url? query
      return { type: :url, value: query }
    else
      return { type: :title, value: query }
    end
  end

  def self.is_url?(url)
    uri = URI.parse(url)
    uri.scheme.present?
  rescue URI::InvalidURIError
    false
  end


  def touch_topics
    Feed.eager_load(:topics).find(id).topics.each do |t|
      t.delete_cache_entries
      t.delete_cache_mix_entries
    end
  end
end
