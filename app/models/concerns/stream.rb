require('paginated_array')

module Stream
  extend ActiveSupport::Concern

  included do
    after_touch   :delete_cache_entries
    after_update  :delete_cache_entries
    after_destroy :delete_cache_entries

    scope :stream_id, ->  (stream_id) {
      where(id: stream_id)
    }
  end

  def stream_id
    id
  end

  def entries_of_stream(page: 1, per_page: nil, newer_than: nil, since: nil)
    Entry.page(page).per(per_page).stream(self)
  end

  def enclosures_of_stream(clazz, page: 1, per_page: nil, newer_than: nil, since: nil)
    clazz.page(page).per(per_page).stream(self)
  end

  def stream_entries(page: 1, per_page: nil, since: nil)
    key = self.class.cache_key_of_entries_of_stream(stream_id,
                                                    page: page,
                                                    per_page: per_page,
                                                    since: since)
    items, count = Rails.cache.fetch(key) do
      items = entries_of_stream(page: page, per_page: per_page, since: since)
      [items.to_a, items.total_count || items.count]
    end

    PaginatedArray.new(items, count)
  end

  def stream_enclosures(clazz, page: 1, per_page: nil, since: nil)
    key = self.class.cache_key_of_enclosures_of_stream(clazz, stream_id,
                                                       page: page,
                                                       per_page: per_page,
                                                       since: since)
    items, count = Rails.cache.fetch(key) do
      items = enclosures_of_stream(page: page, per_page: per_page, since: since)
      [items.to_a, items.total_count || items.count]
    end

    PaginatedArray.new(items, count)
  end

  def delete_cache_entries
    self.class.delete_cache_of_stream(stream_id)
  end

  class_methods do
    def cache_key_of_entries_of_stream(stream_id, page: 1, per_page: nil, since: nil)
      if since.nil?
        "entries_of_#{stream_id}-page(#{page})-per_page(#{per_page})}"
      else
        "entries_of_#{stream_id}-page(#{page})-per_page(#{per_page})-since-#{since.strftime("%Y%m%d")}"
      end
    end

    def cache_key_of_enclosures_of_stream(clazz, stream_id, page: 1, per_page: nil, since: nil)
      if since.nil?
        "#{clazz.name.pluralize}_of_#{stream_id}-page(#{page})-per_page(#{per_page})}"
      else
        "#{clazz.name.pluralize}_of_#{stream_id}-page(#{page})-per_page(#{per_page})-since-#{since.strftime("%Y%m%d")}"
      end
    end

    def delete_cache_of_stream(stream_id)
      Rails.cache.delete_matched("entries_of_#{stream_id}-*")
      Rails.cache.delete_matched("#{Track.name.pluralize}_of_#{stream_id}-*")
      Rails.cache.delete_matched("#{Album.name.pluralize}_of_#{stream_id}-*")
      Rails.cache.delete_matched("#{Playlist.name.pluralize}_of_#{stream_id}-*")
    end
  end
end
