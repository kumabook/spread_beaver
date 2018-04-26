# frozen_string_literal: true

class RSSCrawler < ApplicationJob
  WAITING_SEC_FOR_FEED = 0.25
  queue_as :default

  def perform(type)
    logger.info("Job start")
    feeds = Feed.all
    results = feeds.map do |f|
      sleep(WAITING_SEC_FOR_FEED)
      fetch_latest_entries(type, f)
    end
    update_feed_visuals(feeds) if type == :feedlr
    results
  end

  def fetch_latest_entries(type, feed)
    if type == :feedlr
      fetch_latest_entries_with_feedlr(feed)
    else
      fetch_latest_entries_with_pink_spider(feed)
    end
  end

  def fetch_latest_entries_with_pink_spider(feed)
    crawler_result = Result.new(feed)
    logger.info("Fetch latest entries of #{feed.id}")
    response = PinkSpider.new.fetch_entries_of_feed(feed.url, nil)
    items    = response["items"]
    return crawler_result if items.nil?

    items.each do |entry|
      handle_pink_spider_entry(crawler_result, feed, entry)
    end
    feed.update(crawled: DateTime.now)
    crawler_result
  rescue
    crawler_result
  end

  def handle_pink_spider_entry(crawler_result, feed, entry)
    sleep(WAITING_SEC_FOR_FEED)
    if Entry.find_by(feed_id: feed.id, originId: entry["origin_id"]).present?
      return
    end
    e = Entry.first_or_create_by_pink_spider(entry, feed)
    logger.info("Fetch tracks of #{e.url}")
    crawler_result.append(e, e.crawl)
    update_feed_last_updated(feed, e)
  rescue => err
    logger.error("Failed to fetch #{entry['url']}  #{err}")
    logger.error(err.backtrace)
  end

  def fetch_latest_entries_with_feedlr(feed)
    crawler_result = Result.new(feed)
    client = Feedlr::Client.new(sandbox: false)
    logger.info("Fetch latest entries of #{feed.id}")
    newer_than = feed.crawled&.to_time&.to_i
    cursor = client.stream_entries_contents(feed.id, newerThan: newer_than)

    return crawler_result if cursor.items.nil?

    cursor.items.each do |entry|
      handle_feedlr_entry(crawler_result, feed, entry)
    end
    feed.update(crawled: DateTime.now)
    crawler_result
  end

  def handle_feedlr_entry(crawler_result, feed, entry)
    sleep(WAITING_SEC_FOR_FEED)
    return if Entry.find_by(feed_id: feed.id, originId: entry.originId).present?
    e = Entry.first_or_create_by_feedlr(entry, feed)
    logger.info("Fetch tracks of #{e.url}")
    crawler_result.append(e, e.crawl)
    update_feed_last_updated(feed, e)
  rescue => err
    logger.error("Failed to fetch #{e.url}  #{err}")
    logger.error(err.backtrace)
  end

  def update_feed_visuals(feeds)
    client = Feedlr::Client.new
    feedlr_feeds = client.feeds(feeds.map(&:id))
    return [] if feedlr_feeds.nil?
    feedlr_feeds.map do |feedlr_feed|
      feeds.select { |f| f.id == feedlr_feed.id }.each do |feed|
        feed.update_visuals_with_feedlr(feedlr_feed)
      end
    end
  end

  def create_feeds_on_pink_spider
    Feed.all.each do |f|
      begin
        Feed.find_or_create_by_url(f.url)
      rescue
        puts "#{f.url} seems to be dead"
      end
    end
  end

  def self.build_message_from_results(results)
    message = "Successfully crawling\n"
    message += results.select { |r|
      r.entries.present?
    }.map { |r|
      "Create #{r.entries.count} entries and #{r.tracks.count} tracks from #{r.feed.id}"
    }.join("\n")
    message
  end

  def update_feed_last_updated(feed, entry)
    if feed.lastUpdated.nil? || feed.lastUpdated < entry.published
      feed.lastUpdated = entry.published
    end
  end

  class Result
    attr_reader(:feed, :entries, :tracks, :playlists, :albums)
    def initialize(feed)
      @feed      = feed
      @entries   = []
      @tracks    = []
      @playlists = []
      @albums    = []
    end

    def append(entry, result_hash)
      @entries << entry
      @tracks.concat(result_hash[:tracks])
      @playlists.concat(result_hash[:playlists])
      @albums.concat(result_hash[:albums])
    end
  end

end
