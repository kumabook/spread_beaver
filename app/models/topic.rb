# frozen_string_literal: true
require('paginated_array')

class Topic < ApplicationRecord
  include Escapable
  include Stream
  include Mix

  after_save    :delete_cache
  after_destroy :delete_cache

  after_create :purge_all
  after_destroy :purge_all
  after_save :purge

  has_many :feed_topics, dependent: :destroy
  has_many :feeds      , through: :feed_topics

  self.primary_key = :id

  after_initialize :set_id, if: :new_record?
  before_save      :set_id

  LATEST_ENTRIES_PER_FEED = Setting.latest_entries_per_feed || 3

  scope :locale, -> (locale) {
    where(locale: locale) if locale.present?
  }

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
    PaginatedArray.new(items, entries.count, page, per_page)
  end

  def mix_newer_than
    Time.at(Time.now.to_i - mix_duration)
  end

  def mix_journal
    Journal.topic_mix_journal(self)
  end

  def find_or_create_mix_issue(mix_journal)
    Issue.find_or_create_by(journal: mix_journal,
                            label:   id) do |i|
      i.description = "mix for #{id}"
    end
  end

  def daily_mix_issue_label(time=Time.zone.now)
    time_str = "#{time.strftime('%Y%m%d')}"
    "#{id}-#{time_str}"
  end

  def find_daily_mix_issue(mix_journal, time=Time.zone.now)
    label       = daily_mix_issue_label(time)
    Issue.find_by(journal: mix_journal,
                  label:   label) do |i|
      i.description = "mix for #{label}"
    end
  end

  def find_or_create_daily_mix_issue(mix_journal, time=Time.zone.now)
    label       = daily_mix_issue_label(time)
    Issue.find_or_create_by(journal: mix_journal,
                            label:   label) do |i|
      i.description = "mix for #{label}"
    end
  end

  def daily_mix_issues(mix_journal, period)
    (period.begin.to_i..period.end.to_i).step(1.day)
      .map { |i| Time.zone.at(i) }
      .map { |time| find_daily_mix_issue(mix_journal, time) }
      .compact
  end

  def mix_issues(mix_journal, period=2.week.ago..1.day.ago)
    daily_mix_issues(mix_journal, period) + [find_or_create_mix_issue(mix_journal)]
  end

  def find_or_create_dummy_entry
    feed = Feed.find_or_create_dummy_for_topic(self)
    FeedTopic.find_or_create_by(topic_id: self.id, feed_id: feed.id)
    Entry.find_or_create_dummy_for_feed(feed)
  end

  def self.topics(locale=nil)
    key = locale.nil? ? "topics_all" : "topics_#{locale}"
    Rails.cache.fetch(key) {
      Topic.locale(locale)
           .order("engagement DESC")
           .where('engagement >= 0').to_a
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
    Rails.cache.delete_matched("topics_*")
  end
end
