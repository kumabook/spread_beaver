# frozen_string_literal: true
class Issue < ApplicationRecord
  include Escapable
  include Stream
  include Mix

  TIME_OFFSET_DAILY_ISSUE = -30.hours

  enum state: { draft: 0, published: 1 }

  has_many :entry_issues    , -> { order("entry_issues.engagement DESC") }    , dependent: :destroy
  has_many :enclosure_issues, -> { order("enclosure_issues.engagement DESC") }, dependent: :destroy
  has_many :entries         , through: :entry_issues
  has_many :enclosures      , through: :enclosure_issues
  has_many :tracks          , through: :enclosure_issues, source: :enclosure, source_type: Track.name
  has_many :albums          , through: :enclosure_issues, source: :enclosure, source_type: Album.name
  has_many :playlists       , through: :enclosure_issues, source: :enclosure, source_type: Playlist.name

  belongs_to :journal

  self.primary_key = :id

  def date
    Time.zone.strptime(label, "%Y%m%d")
  rescue
    nil
  end

  def collect_entries_of_topic(topic)
    period  = (date + TIME_OFFSET_DAILY_ISSUE)..(date + 24.hours)
    entries = Entry.topic(topic)
                   .period(period)
                   .order(published: :desc)
                   .select(&:has_visual?)
    entries = Mix.mix_up_and_paginate(entries,
                                      Topic::LATEST_ENTRIES_PER_FEED,
                                      1,
                                      nil)
    if entries.empty?
      logger.info("Failed to create journal because there is no entry")
      return
    end
    count = 0
    entries.each_with_index do |entry, i|
      EntryIssue.find_or_create_by(entry_id: entry.id, issue_id: id) do |ei|
        count += 1
        ei.engagement = (entries.count - i) * 10
      end
    end
    logger.info("Add #{count} entries to #{label} of #{journal.label}")
  end

  def entries_of_stream(page: 1, per_page: nil, since: nil)
    Entry.page(page).per(per_page).issue(self)
  end
end
