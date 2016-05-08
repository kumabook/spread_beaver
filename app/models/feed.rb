class Feed < ActiveRecord::Base
  include Escapable
  has_many :entries
  has_many :feed_topics
  has_many :topics, through: :feed_topics
  self.primary_key = :id

  scope :search, -> (query) {
    q = search_query(query)
    case q[:type]
    when :all
      includes(:topics).all
    when :topic
      joins(:topics).where(topics: { label: q[:value]})
    when :url
      includes(:topics).where(website: q[:value])
    when :title
      includes(:topics).where(arel_table[:title].matches("%#{q[:value]}%"))
    else
      includes(:topics).all
    end
  }

  scope :locale, -> (locale) {
    where(language: locale) if locale.present?
  }

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

  def self.find_or_create_with_ids(feedIds)
    client = Feedlr::Client.new(sandbox: false)
    feeds = client.feeds(feedIds)
    return [] if feeds.nil?
    feeds.map do |feed|
      Feed.first_or_create_by_feedlr(feed)
    end
  end

  def self.fetch_all_latest_entries
    feeds = Feed.all
    Feed.update_visuals(feeds)
    feeds.each { |f| f.fetch_latest_entries }
  end

  def self.update_visuals(feeds)
    client = Feedlr::Client.new(sandbox: false)
    feedlr_feeds = client.feeds(feeds.map { |f| f.id })
    return [] if feedlr_feeds.nil?
    feedlr_feeds.map do |feedlr_feed|
      feeds.select { |f| f.id == feedlr_feed.id }.each do |feed|
        puts "Update visuals of #{feedlr_feed.id}"
        feed.update_visuals_with_feedlr(feedlr_feed)
      end
    end
  end

  def update_visuals_with_feedlr(feed)
    self.visualUrl   = feed.visualUrl if feed.visualUrl.present?
    self.coverUrl    = feed.coverUrl  if feed.coverUrl.present?
    self.iconUrl     = feed.iconUrl   if feed.iconUrl.present?
    save
  end

  def fetch_latest_entries
    client = Feedlr::Client.new(sandbox: false)
    puts "Fetch latest entries of #{id}"
    newer_than = crawled.present? ? crawled.to_time.to_i : nil
    sleep(0.25)
    cursor = client.stream_entries_contents(id, newerThan: newer_than)
    cursor.items.each do |entry|
      sleep(0.1)
      e = Entry.first_or_create_by_feedlr(entry, self)
      puts "Fetch tracks of #{e.url}"
      playlist = e.fetch_playlist
      playlist.create_tracks.each do |track|
        puts "  Create track #{track.provider} #{track.identifier}"
      end
      if self.lastUpdated.nil? || self.lastUpdated < e.published
        self.lastUpdated = e.published
      end
    end
    self.crawled = DateTime.now
    save
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

end
