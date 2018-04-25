# frozen_string_literal: true
class EntryEnclosure < ApplicationRecord
  include EntryMark

  enum enclosure_provider: [:Raw, :Custom, :YouTube, :SoundCloud, :Spotify, :AppleMusic]

  has_one :entry, autosave: false
  belongs_to :entry
  belongs_to :enclosure, polymorphic: true, counter_cache: :entries_count, touch: true

  scope :entry_count,     -> { group(:enclosure_id).order('count_entry_id DESC').count('entry_id') }
  scope :enclosure_count, -> { group(:entry_id).order('count_enclosure_id DESC').count('enclosure_id') }
  scope :feed_count, -> {
    group('enclosure_id')
      .joins(:entry)
      .order('count_entries_feed_id DESC')
      .distinct.count('entries.feed_id')
  }
  scope :locale, -> (locale) {
    joins(entry: :feed).where(feeds: { language: locale}) if locale.present?
  }
  scope :provider, -> (provider) {
    where(enclosure_provider: provider) if provider.present?
  }
end
