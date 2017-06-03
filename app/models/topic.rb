require('paginated_array')

class Topic < ApplicationRecord
  include Escapable
  include Stream
  include Mix
  after_save    :delete_cache
  after_destroy :delete_cache

  has_many :feed_topics, dependent: :destroy
  has_many :feeds      , through: :feed_topics

  self.primary_key = :id

  after_initialize :set_id, if: :new_record?
  before_save      :set_id

  LATEST_ENTRIES_PER_FEED = Setting.latest_entries_per_feed || 3

  def entries_of_stream(page: 1, per_page: nil, since: nil)
    entries = nil
    if since.present?
      entries = Entry.topic(self).latest(since)
    else
      entries = Entry.topic(self).latest(mix_newer_than)
    end
    items = Mix::mix_up_and_paginate(entries,
                                     LATEST_ENTRIES_PER_FEED,
                                     page,
                                     per_page)
    PaginatedArray.new(items, entries.count)
  end

  def mix_newer_than
    Time.at(Time.now.to_i - mix_duration)
  end

  def self.topics
    Rails.cache.fetch("topics") {
      Topic.order("engagement DESC").where('engagement >= 0').to_a
    }
  end

  private
  def set_id
    self.id = "topic/#{self.label}"
  end

  def delete_cache
    Topic.delete_cache
  end

  def self.delete_cache
    Rails.cache.delete("topics")
  end
end
