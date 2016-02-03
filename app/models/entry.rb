# coding: utf-8
class Entry < ActiveRecord::Base
  belongs_to :feed
  has_many :entry_tracks
  has_many :user_entries
  has_many :users,  through: :user_entries
  has_many :tracks, through: :entry_tracks
  self.primary_key = :id
  def self.first_or_create_by_feedlr(entry, feed)
    e = Entry.find_or_create_by(id: entry.id) do |e|
      e.title       = entry.title
      e.content     = entry.content.to_json
      e.summary     = entry.summary.to_json
      e.author      = entry.author

      e.alternate   = entry.alternate.to_json
      e.origin      = entry.origin.to_json
      e.keywords    = entry.keywords.to_json
      e.visual      = entry.visual.to_json
      e.tags        = entry.tags.to_json
      e.categories  = entry.categories.to_json
      e.unread      = entry.unread

      e.engagement  = entry.engagement
      e.actionTimestamp = entry.actionTimestamp
      e.enclosure   = entry.enclosure.to_json
      e.fingerprint = entry.fingerprint
      e.originId    = entry.originId
      e.sid         = entry.sid

      e.crawled     = entry.crawled
      e.recrawled   = entry.recrawled
      e.published   = entry.published
      e.updated     = entry.updated
      e.feed        = feed
    end
    e.save
    e
  end

  def url
    originId
  end
end
