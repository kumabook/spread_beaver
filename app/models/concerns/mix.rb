module Mix
  class Query
    attr_reader(:since, :entries_per_feed)
    def initialize(since = 3.days.ago, entries_per_feed = 3)
      @since            = since
      @entries_per_feed = entries_per_feed
    end
    def cache_key
      if @since.nil?
        "entries_per_feed(#{entries_per_feed})"
      else
        "since-#{since.strftime("%Y%m%d")}-entries_per_feed(#{entries_per_feed})"
      end
    end
  end
  extend ActiveSupport::Concern

  included do
    after_touch   :delete_cache_mix_entries
    after_update  :delete_cache_mix_entries
    after_destroy :delete_cache_mix_entries
  end

  def stream_id
    id
  end

  def entries_of_mix(page: 1, per_page: nil, newer_than: nil, query: nil)
    [] # override subclass
  end

  def mix_entries(page: 1, per_page: nil, query: nil)
    key = self.class.cache_key_of_entries_of_mix(stream_id,
                                                 page: page,
                                                 per_page: per_page,
                                                 query: query)
    items, count = Rails.cache.fetch(key) do
      items = entries_of_mix(page: page, per_page: per_page, query: query)
      [items.to_a, items.total_count || items.count]
    end

    PaginatedEntryArray.new(items, count)
  end

  def delete_cache_mix_entries
    self.class.delete_cache_of_mix(stream_id)
  end

  class_methods do
    def cache_key_of_entries_of_mix(stream_id, page: 1, per_page: nil, query: nil)
      "entries_of_#{stream_id}-page(#{page})-per_page(#{per_page})-query(#{query.cache_key})"
    end

    def delete_cache_of_mix(stream_id)
      Rails.cache.delete_matched("entries_of_mix_#{stream_id}-*")
    end
  end

  def self.mix_up_and_paginate(entries, entries_per_feed, page, per_page)
    items = sort_one_by_one_by_feed(entries, entries_per_feed: entries_per_feed)
    if per_page.present?
      page   = 1 if page < 1
      offset = (page - 1) * per_page
      items[offset...offset+per_page] || []
    else
      items
    end
  end

  def self.sort_one_by_one_by_feed(entries, entries_per_feed: 3)
    entries_list = entries.map { |entry| entry.feed_id }
                          .uniq
                          .map do |id|
      entries.select { |e| e.feed_id == id }.first(entries_per_feed)
    end

    (0...entries_per_feed).to_a
      .flat_map { |i| entries_list.map { |list| list[i] }}
      .select   { |a| a.present? }
  end
end
