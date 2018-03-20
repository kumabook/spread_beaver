require('paginated_array')

module Mix
  class Query
    attr_reader(:period, :entries_per_feed, :type, :locale, :provider)
    def initialize(period          = -Float::INFINITY..Float::INFINITY,
                   type            = :hot,
                   locale:           nil,
                   provider:         nil,
                   entries_per_feed: 3)
      @period           = period
      @type             = type
      @locale           = locale
      @provider         = provider
      @entries_per_feed = entries_per_feed
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
      return time.strftime("%Y%m%d")
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

  def entries_of_mix(page: 1, per_page: nil,query: nil)
    case query.type
    when :hot
      Entry.hot_items(stream:   self,
                      period:   query.period,
                      locale:   query.locale,
                      page:     page,
                      per_page: per_page)
    when :popular
      Entry.popular_items(stream:   self,
                          period:   query.period,
                          locale:   query.locale,
                          page:     page,
                          per_page: per_page)
    when :featured
      # not support for entries
    end
  end

  def enclosures_of_mix(clazz, page: 1, per_page: nil, query: nil)
    case query.type
    when :hot
      clazz.hot_items(stream:   self,
                      period:   query.period,
                      locale:   query.locale,
                      provider: query.provider,
                      page:     page,
                      per_page: per_page)
    when :popular
      clazz.popular_items(stream:   self,
                          period:   query.period,
                          locale:   query.locale,
                          provider: query.provider,
                          page:     page,
                          per_page: per_page)
    when :featured
      clazz.most_featured_items(stream:   self,
                                period:   query.period,
                                locale:   query.locale,
                                provider: query.provider,
                                page:     page,
                                per_page: per_page)
    when :picked
      clazz.most_picked_items(stream:   self,
                              period:   query.period,
                              locale:   query.locale,
                              provider: query.provider,
                              page:     page,
                              per_page: per_page)
    when :engaging
      clazz.most_engaging_items(stream:   self,
                                period:   query.period,
                                locale:   query.locale,
                                provider: query.provider,
                                page:     page,
                                per_page: per_page)
    end
  end

  def mix_entries(page: 1, per_page: nil, query: nil)
    key = self.class.cache_key_of_entries_of_mix(stream_id,
                                                 page:     page,
                                                 per_page: per_page,
                                                 query:    query)
    items, count = Rails.cache.fetch(key) do
      items = entries_of_mix(page: page, per_page: per_page, query: query)
      [items.to_a, items.total_count || items.count]
    end

    PaginatedArray.new(items, count)
  end

  def mix_enclosures(clazz, page: 1, per_page: nil, query: nil)
    key = self.class.cache_key_of_enclosures_of_mix(clazz,
                                                    stream_id,
                                                    page:     page,
                                                    per_page: per_page,
                                                    query:    query)
    items, count = Rails.cache.fetch(key) do
      items = enclosures_of_mix(clazz, page: page, per_page: per_page, query: query)
      [items.to_a, items.total_count || items.count]
    end
    PaginatedArray.new(items, count)
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
