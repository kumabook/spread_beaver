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

  def entries_of_stream(page: 1, per_page: nil, since: nil)
    Entry.page(page).per(per_page).topic(self)
  end

  def entries_of_mix(page: 1, per_page: nil, query: Mix::Query.new())
    entries = Entry.topic(self).latest(query.since)
    items   = Mix::mix_up_and_paginate(entries, query.entries_per_feed, page, per_page)
    PaginatedArray.new(items, entries.count)
  end

  def self.topics
    Rails.cache.fetch("topics") {
      Topic.order("engagement DESC").all.to_a
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
