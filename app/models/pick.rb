# frozen_string_literal: true
class Pick < ApplicationRecord
  include EnclosureMark
  belongs_to :enclosure , counter_cache: :pick_count, touch: true
  belongs_to :container , class_name: "Enclosure", foreign_key: "container_id"

  scope :pick_count, -> {
    group(:enclosure_id).order("count_container_id DESC").count("container_id")
  }

  scope :feed, -> (feed) {
    joins(container: :entries).where(entries: { feed_id: feed.id })
  }
  scope :keyword, -> (keyword) {
    joins(container: { entries: :keywords })
      .where(keywords: { id: keyword.id })
  }
  scope :tag, -> (tag) {
    joins(container: { entries: :tags }).where(tags: { id: tag.id })
  }
  scope :topic,      -> (topic)    {
    joins(container: { entries: { feed: :topics }})
      .where(topics: { id: topic.id })
  }
  scope :category, -> (category) {
    joins(container: { entries: { feed: { subscriptions: :categories }}})
      .where(categories: { id: category.id })
  }
  scope :issue, -> (issue) {
    joins(container: :issues).where(issues: { id: issue.id })
  }
  scope :issues, -> (issues) {
    joins(container: :issues).where(issues: { id: issues.map(&:id) })
  }
end
