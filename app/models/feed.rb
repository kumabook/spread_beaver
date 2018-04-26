# frozen_string_literal: true
require("pink_spider")
class Feed < ApplicationRecord
  include Escapable
  include Stream
  include Mix
  after_touch   :touch_topics
  after_save    :delete_cache_of_search_results
  after_destroy :delete_cache_of_search_results

  has_many :entries
  has_many :feed_topics,   dependent: :destroy
  has_many :topics     ,   through:   :feed_topics
  has_many :subscriptions, dependent: :destroy

  self.primary_key = :id

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

  def url
    id && id[5..-1] # eliminate feed/
  end

  def has_thumbnail?
    visualUrl.present?
  end

  def thumbnail_url
    visualUrl
  end

  def self.delete_cache_of_search_results
    Rails.cache.delete_matched("feeds_of_search_by-*")
  end

  def delete_cache_of_search_results
    Feed.delete_cache_of_search_results
  end

  def self.search_by(query: "", locale: "ja", page: 1, per_page: 15)
    key = "feeds_of_search_by-page(#{page})-page_page(#{per_page})-#{query}-#{locale}"
    Rails.cache.fetch(key) do
      Feed.page(page)
          .per(per_page)
          .search(query)
          .locale(locale)
          .where("velocity >= 0")
          .includes([:feed_topics])
          .order("velocity DESC").to_a
    end
  end

  def self.find_or_create_by_url(url, crawler_type=:pink_spider)
    if crawler_type == :feedlr
      Feed.find_or_create_by_ids_with_feedlr(["feed/#{url}"]).first
    else
      Feed.find_or_create_by_url_on_pink_spider(url)
    end
  rescue
    nil
  end

  def self.find_or_create_by_ids_with_feedlr(feed_ids)
    client = Feedlr::Client.new(sandbox: false)
    feeds = client.feeds(feed_ids)
    return [] if feeds.nil?
    feeds.map do |feed|
      Feed.first_or_create_by_feedlr(feed)
    end
  end

  def self.first_or_create_by_feedlr(feed)
    Feed.find_or_create_by(id: feed.id) do |f|
      f.title       = feed.title
      f.description = feed.description || ""
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
        f.topics = feed.topics.map { |t| Topic.find_or_create_by(label: t) }
      end
    end
  end

  def self.first_or_create_by_pink_spider(feed)
    Feed.find_or_create_by(id: "feed/#{feed['url']}") do |f|
      f.title       = feed["title"]
      f.description = feed["description"] || ""
      f.website     = feed["website"]
      f.visualUrl   = feed["visual_url"]
      f.coverUrl    = feed["cover_url"]
      f.iconUrl     = feed["icon_url"]
      f.language    = feed["language"]
      f.velocity    = feed["velocity"]

      if feed["topics"].present?
        f.topics = feed["topics"].map { |t| Topic.find_or_create_by(label: t) }
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

  def self.find_or_create_by_url_on_pink_spider(url)
    feed = PinkSpider.new.create_feed(url)
    Feed.first_or_create_by_pink_spider(feed)
  end

  def label
    title
  end

  def as_json(options = {})
    h                = super(options)
    h["lastUpdated"] = lastUpdated.present? ? lastUpdated.to_time.to_i * 1000 : nil
    h["topics"]      = topics.map(&:label)
    h
  end

  def self.search_query(query)
    if query.blank?
      { type: :all }
    elsif query.start_with? "#"
      { type: :topic, value: query[1..-1] }
    elsif is_url? query
      { type: :url, value: query }
    else
      { type: :title, value: query }
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
