class Feed < ActiveRecord::Base
  has_many :entries
  self.primary_key = :id
  def self.first_or_create_by_feedlr(feed)
    Feed.find_or_create_by(id: feed.id) do |f|
      f.title       = feed.title
      f.description = feed.description
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
      f.topics      = feed.topics

=begin
      f.facebookLikes     = feed.facebookLikes,
      f.facebookUsername  = feed.facebookUsername,
      f.feedId            = feed.feedId,
      f.twitterFollowers  = feed.twitterFollowers,
      f.twitterScreenName = feed.twitterScreenName,
=end
    end
  end

  def self.fetch_all_latest_entries
    Feed.all.each do |f|
      f.fetch_latest_entries
    end
  end

  def fetch_latest_entries
    client = Feedlr::Client.new(sandbox: false)
    puts "Fetch latest entries of #{id}"
    cursor = client.stream_entries_contents(id, newerThan: crawled.to_time.to_i)
    cursor.items.each do |entry|
      e = Entry.first_or_create_by_feedlr(entry, self)
      puts "Fetch tracks of entry(id: #{e.originId})"
      playlist = e.fetch_playlist
      playlist.create_tracks.each do |track|
        puts "  Create track #{track.provider} #{track.identifier}"
      end
    end
    self.crawled = DateTime.now
    save
  end

  def escape
    clone = self.dup
    clone.id = CGI.escape self.id
    clone
  end

  def unescape
    clone = self.dup
    clone.id = CGI.unescape self.id
    clone
  end
end
