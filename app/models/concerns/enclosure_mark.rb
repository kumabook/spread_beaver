# frozen_string_literal: true

module EnclosureMark
  extend ActiveSupport::Concern
  included do
    include Streamable
    scope :period, ->(period) {
      where({ table_name.to_sym => { created_at: period }})
    }
    scope :user_count, -> {
      group(:enclosure_id).order("count_user_id DESC").count("user_id")
    }
    scope :locale, ->(locale) {
      joins(:user).where({ users: { locale: locale} }) if locale.present?
    }
    scope :provider, ->(provider) {
      joins(:enclosure).where(enclosures: { provider: provider }) if provider.present?
    }
  end

  class_methods do
    def include_stream_scopes
      scope :feed, ->(feed) {
        joins(enclosure: :entries).where(entries: { feed_id: feed.id })
      }
      scope :keyword, ->(keyword) {
        joins(enclosure: { entries: :keywords })
          .where(keywords: { id: keyword.id })
      }
      scope :tag, ->(tag) {
        joins(enclosure: { entries: :tags }).where(tags: { id: tag.id })
      }
      scope :topic,      ->(topic)    {
        joins(enclosure: { entries: { feed: :topics }})
          .where(topics: { id: topic.id })
      }
      scope :category, ->(category) {
        joins(enclosure: { entries: { feed: { subscriptions: :categories }}})
          .where(categories: { id: category.id })
      }
      scope :issue, ->(issue) {
        joins(enclosure: { entries: :issues }).where(issues: { id: issue.id })
      }
    end

    def marker_params(user, id, type=nil)
      {
        user:           user,
        enclosure_id:   id,
        enclosure_type: type,
      }
    end
  end
end
