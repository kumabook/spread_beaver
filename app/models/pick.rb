# frozen_string_literal: true

class Pick < ApplicationRecord
  include EnclosureMark
  belongs_to :track   , foreign_key: "enclosure_id", counter_cache: :pick_count, touch: true
  belongs_to :playlist, foreign_key: "container_id"

  scope :pick_count, -> {
    group(:enclosure_id).order("count_container_id DESC").count("container_id")
  }

  scope :feed, ->(feed, _) {
    joins(playlist: :entries).where(entries: { feed_id: feed.id })
  }
  scope :keyword, ->(keyword, _) {
    joins(playlist: { entries: :keywords })
      .where(keywords: { id: keyword.id })
  }
  scope :tag, ->(tag, _) {
    joins(playlist: { entries: :tags }).where(tags: { id: tag.id })
  }
  scope :topic, ->(topic, _)    {
    joins(playlist: { entries: { feed: :topics }})
      .where(topics: { id: topic.id })
  }
  scope :category, ->(category, _) {
    joins(playlist: { entries: { feed: { subscriptions: :categories }}})
      .where(categories: { id: category.id })
  }
  scope :issue, ->(issue, _) {
    joins(playlist: :issues).where(issues: { id: issue.id })
  }
  scope :issues, ->(issues, _) {
    joins(playlist: :issues).where(issues: { id: issues.pluck(:id) })
  }
end
