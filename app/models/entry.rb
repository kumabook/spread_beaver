# coding: utf-8
class Entry < ActiveRecord::Base
  belongs_to :feed
  has_many :entry_tracks
  has_many :user_entries
  has_many :users,  through: :user_entries
  has_many :tracks, through: :entry_tracks
  self.primary_key = :id

  scope :with_content,  ->         { includes(:tracks) }
  scope :with_detail,   ->         { includes(:users).includes(:tracks) }
  scope :latest,        ->  (time) { where("published > ?", time).order('published DESC').with_content }
  scope :popular,       ->         { joins(:users).order('saved_count DESC').with_content }
  scope :subscriptions, ->    (ss) { where(feed: ss.map { |s| s.feed_id }).order('published DESC').with_content }
  scope :feed,          ->  (feed) { where(feed: feed).order('published DESC').with_content }
  scope :feeds,         -> (feeds) { where(feed: feeds).order('published DESC').with_content }
  scope :saved,         ->   (uid) { joins(:users).includes(:tracks).where(users: { id: uid }) }

  JSON_ATTRS = ['content', 'categories', 'summary', 'alternate', 'origin', 'keywords', 'visual']

  def self.first_or_create_by_feedlr(entry, feed)
    e = Entry.find_or_create_by(id: entry.id) do |e|
      e.title       = entry.title
      e.content     = entry.content.to_json
      e.summary     = entry.summary.to_json
      e.author      = entry.author

      e.alternate   = entry.alternate.to_json
      e.origin      = entry.origin.to_json
      e.keywords    = entry.keywords.to_json
      e.visual      = entry.visual.to_json
      e.tags        = entry.tags.to_json
      e.categories  = entry.categories.to_json
      e.unread      = entry.unread

      e.engagement  = entry.engagement
      e.actionTimestamp = entry.actionTimestamp
      e.enclosure   = entry.enclosure.to_json
      e.fingerprint = entry.fingerprint
      e.originId    = normalize_originId(entry.originId, feed)
      e.sid         = entry.sid

      e.crawled     = Time.at(entry.crawled / 1000)
      e.published   = Time.at(entry.published / 1000)
      e.recrawled   = entry.recrawled.present? ? Time.at(entry.recrawled / 1000) : nil
      e.updated     = entry.updated.present?   ? Time.at(entry.updated / 1000) : nil
      e.feed        = feed
    end
    e.save
    e
  end

  def self.normalize_originId(origin_id, feed)
    uri = URI(origin_id)
    return origin_id if !uri.scheme.nil? && !uri.host.nil?
    website_uri = URI(feed.website)
    uri.scheme = website_uri.scheme
    uri.host = website_uri.host
    return uri.to_s
  end

  def url
    originId
  end

  def has_visual?
    visual = JSON.load(self.visual)
    visual.present? && visual['url'].present? && visual['url'] != 'none'
  end

  def self.latest_entries(entries_per_feed: 3, since: 3.days.ago)
    # TODO: Add page and per_page if need be
    entries = Entry.latest(since)
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
    raise ArgumentError, "Parameter must be not nil" if from.nil? || to.nil?
    # TODO: Add page and per_page if need be
    user_count_hash = UserEntry.period(from, to).user_count
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

  def fetch_playlist
    url = "http://musicfav-cloud.herokuapp.com/playlistify"
    response = RestClient.get url, params: { url: originId}, :accept => :json
    return if response.code != 200
    hash = JSON.parse(response)
    Playlist.new(hash['id'], hash['url'], hash['tracks'], self)
  end

  def as_json(options = {})
    h              = super(options)
    h['crawled']   = crawled.to_time.to_i * 1000
    h['published'] = published.to_time.to_i * 1000
    h['recrawled'] = recrawled.present? ? recrawled.to_time.to_i * 1000 : nil
    h['updated']   = updated.present?   ? updated.to_time.to_i   * 1000 : nil
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
    hash         = as_content_json
    hash['tags'] = users.map  { |u| u.as_user_tag }
    hash
  end
end
