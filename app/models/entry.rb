# coding: utf-8
class Entry < ActiveRecord::Base
  belongs_to :feed
  has_many :entry_tracks
  has_many :user_entries
  has_many :users,  through: :user_entries
  has_many :tracks, through: :entry_tracks
  self.primary_key = :id
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

  def fetch_playlist
    url = "http://musicfav-cloud.herokuapp.com/playlistify"
    response = RestClient.get url, params: { url: originId}, :accept => :json
    return if response.code != 200
    hash = JSON.parse(response)
    Playlist.new(hash['id'], hash['url'], hash['tracks'], self)
  end

  def as_detail_json
    hash = as_json
    hash['engagement'] = users.size
    hash['tags']       = users.map  { |u| u.as_user_tag }
    hash['enclosure']  = tracks.map { |t| t.as_enclosure }

    ['summary', 'alternate', 'origin', 'keywords', 'visual'].each do |key|
      hash[key]    = JSON.load(hash[key])
    end
    hash
  end
end
