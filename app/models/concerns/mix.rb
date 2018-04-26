# coding: utf-8
# frozen_string_literal: true
require("paginated_array")

module Mix
  class Query
    attr_reader(:period, :entries_per_feed, :type, :locale, :provider)
    attr_accessor(:use_stream_for_pick)
    def initialize(period          = -Float::INFINITY..Float::INFINITY,
                   type            = :hot,
                   locale:           nil,
                   provider:         nil,
                   entries_per_feed: 3)
      @period           = period
      @type             = type
      @locale           = locale
      @provider         = provider.nil? ? nil : [provider].flatten
      @entries_per_feed = entries_per_feed
      @use_stream_for_pick = true
    end
    def no_locale
      Query.new(@period, @type, locale: nil, provider: @provider, entries_per_feed: @entries_per_feed)
    end

    def twice_past
      Query.new(@period.twice_past, @type, locale: nil, provider: @provider, entries_per_feed: @entries_per_feed)
    end

    def exclude_sound_cloud
      if @provider.nil?
        self.dup
      else
        Query.new(@period, @type, locale: nil, provider: @provider.reject { |pr| pr == "SoundCloud" }, entries_per_feed: @entries_per_feed)
      end
    end

    def cache_key
      prefix = ""
      prefix += "#{time2key(period.begin)}-#{time2key(period.end)}-" if @period.present?
      prefix += "-#{locale}" if @locale.present?
      prefix += "-#{provider}" if @provider.present?
      "#{prefix}#{type}-entries_per_feed(#{entries_per_feed})"
    end

    private

    def time2key(time)
      return "inf" if time == Float::INFINITY
      return "neg_inf" if time == -Float::INFINITY
      time.strftime("%Y%m%d")
    end
  end
  extend ActiveSupport::Concern

  def self.mix_types
    ["engaging", "hot", "popular", "featured", "picked"]
  end

  def self.stream_ids
    Topic.all.map(&:id)
  end

  included do
    after_touch   :delete_cache_mix_entries
    after_update  :delete_cache_mix_entries
    after_destroy :delete_cache_mix_entries
  end

  def stream_id
    id
  end

  def entries_of_mix(page: 1, per_page: nil, query: nil)
    case query.type
    when :hot
      Entry.hot_items(stream: self, query: query, page: page, per_page: per_page)
    when :popular
      Entry.popular_items(stream: self, query: query, page: page, per_page: per_page)
    when :featured
      # not support for entries
    end
  end

  def enclosures_of_mix(clazz, page: 1, per_page: nil, query: nil)
    case query.type
    when :hot
      clazz.hot_items(stream: self, query: query, page: page, per_page: per_page)
    when :popular
      clazz.popular_items(stream: self, query: query, page: page, per_page: per_page)
    when :featured
      clazz.most_featured_items(stream: self, query: query, page: page, per_page: per_page)
    when :picked
      clazz.most_picked_items(stream: self, query: query, page: page, per_page: per_page)
    when :engaging
      clazz.most_engaging_items(stream: self, query: query, page: page, per_page: per_page)
    end
  end

  def mix_entries(page: 1, per_page: nil, query: nil, cache_options: nil)
    key = self.class.cache_key_of_entries_of_mix(stream_id,
                                                 page:     page,
                                                 per_page: per_page,
                                                 query:    query)
    PaginatedArray.from_cache(
      Rails.cache.fetch(key, cache_options) do
        entries_of_mix(page: page, per_page: per_page, query: query)&.to_cache
      end
    )
  end

  def mix_enclosures(clazz, page: 1, per_page: nil, query: nil, cache_options: nil)
    key = self.class.cache_key_of_enclosures_of_mix(clazz,
                                                    stream_id,
                                                    page:     page,
                                                    per_page: per_page,
                                                    query:    query)
    PaginatedArray.from_cache(
      Rails.cache.fetch(key, cache_options) do
        enclosures_of_mix(clazz, page: page, per_page: per_page, query: query)&.to_cache
      end
    )
  end

  def delete_cache_mix_entries
    self.class.delete_cache_of_mix(stream_id)
  end

  class_methods do
    def cache_key_of_entries_of_mix(stream_id, page: 1, per_page: nil, query: nil)
      "entries_of_#{stream_id}-page(#{page})-per_page(#{per_page})-query(#{query.cache_key})"
    end

    def cache_key_of_enclosures_of_mix(clazz, stream_id, page: 1, per_page: nil, query: nil)
      "#{clazz.name.pluralize}_of_#{stream_id}-page(#{page})-per_page(#{per_page})-query(#{query.cache_key})"
    end

    def delete_cache_of_mix(stream_id)
      Rails.cache.delete_matched("entries_of_#{stream_id}-*")
      Rails.cache.delete_matched("#{Track.name.pluralize}_of_#{stream_id}-*")
      Rails.cache.delete_matched("#{Album.name.pluralize}_of_#{stream_id}-*")
      Rails.cache.delete_matched("#{Playlist.name.pluralize}_of_#{stream_id}-*")
    end
  end

  def self.mix_up_and_paginate(entries, entries_per_feed, page, per_page)
    items = sort_one_by_one_by_feed(entries, entries_per_feed)
    if per_page.present?
      page   = 1 if page < 1
      offset = (page - 1) * per_page
      items[offset...offset+per_page] || []
    else
      items
    end
  end

  def self.sort_one_by_one_by_feed(entries, entries_per_feed)
    entries_list = entries.map(&:feed_id)
                          .uniq
                          .map do |id|
      entries.select { |e| e.feed_id == id }.first(entries_per_feed)
    end

    (0...entries_per_feed).to_a
                          .flat_map { |i| entries_list.map { |list| list[i] } }
                          .select(&:present?)
  end

  def self.items_from_count_hash(clazz, count_hash, page: 1, per_page: PER_PAGE)
    total_count   = count_hash.keys.count
    sorted_hashes = PaginatedArray::sort_and_paginate_count_hash(count_hash, page: page, per_page: per_page)
    items = clazz.with_content.find(sorted_hashes.map { |h| h[:id] })
    sorted_items = sorted_hashes.map { |h|
      item = items.select { |t| t.id == h[:id] }.first
      item.engagement = count_hash[item.id]
      item
    }
    PaginatedArray.new(sorted_items, total_count)
  end
end
