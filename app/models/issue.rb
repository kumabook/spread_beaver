class Issue < ApplicationRecord
  include Escapable
  include Stream
  include Mix

  enum state: { draft: 0, published: 1 }

  has_many :entry_issues    , ->{order("entry_issues.engagement DESC")}    , dependent: :destroy
  has_many :enclosure_issues, ->{order("enclosure_issues.engagement DESC")}, dependent: :destroy
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
    entries = Entry.topic(topic).period((date - 6.hours)..(date + 24.hours))
    entries = Entry.topic(topic).period(date..date.tomorrow)
                   .select { |entry| entry.has_visual? }
    entries = Mix::mix_up_and_paginate(entries,
                                       Topic::LATEST_ENTRIES_PER_FEED,
                                       1,
                                       nil)
    if entries.empty?
      logger.info("Failed to create journal because there is no entry")
      return
    end
    entries.each_with_index do |entry, i|
      ej = EntryIssue.find_or_create_by(entry_id: entry.id,
                                        issue_id: id)
      ej.update_attributes(engagement: (entries.count - i) * 10)
    end
    first_entry = entries.find {|e| e.tracks.count > 0 }
    first_entry = entries.first if first_entry.nil?
    first_ej    = EntryIssue.find_or_create_by(entry_id: first_entry.id,
                                               issue_id: id)
    first_ej.update_attributes(engagement: (entries.count + 1) * 10)
    logger.info("Add #{entries.count} entries to Create daily issue: #{label} #{journal.label}")
  end

  def entries_of_stream(page: 1, per_page: nil, since: nil)
    Entry.page(page).per(per_page).issue(self)
  end
end
