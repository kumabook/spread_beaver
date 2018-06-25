# frozen_string_literal: true

class EnclosureArtist < ApplicationRecord
  include EnclosureMark
  belongs_to :enclosure, touch: true, polymorphic: true
  belongs_to :artist

  scope :feed, ->(feed) {
    joins(artist: :entries).where(entries: { feed_id: feed.id })
  }
  scope :keyword, ->(keyword) {
    joins(artist: { entries: :keywords })
      .where(keywords: { id: keyword.id })
  }
  scope :tag, ->(tag) {
    joins(artist: { entries: :tags }).where(tags: { id: tag.id })
  }
  scope :topic,      ->(topic)    {
    joins(container: { entries: { feed: :topics }})
      .where(topics: { id: topic.id })
  }
  scope :category, ->(category) {
    joins(artist: { entries: { feed: { subscriptions: :categories }}})
      .where(categories: { id: category.id })
  }
  scope :issue, ->(issue) {
    joins(artist: :issues).where(issues: { id: issue.id })
  }
  scope :issues, ->(issues) {
    joins(artist: :issues).where(issues: { id: issues.pluck(:id) })
  }
end
