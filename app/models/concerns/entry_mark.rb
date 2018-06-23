# frozen_string_literal: true

module EntryMark
  extend ActiveSupport::Concern
  included do
    scope :stream, ->(s, _) {
      if s.is_a?(Feed)
        feed(s)
      elsif s.is_a?(Keyword)
        keyword(s)
      elsif s.is_a?(Tag)
        tag(s)
      elsif s.is_a?(Topic)
        topic(s)
      elsif s.is_a?(Category)
        category(s)
      elsif s.is_a?(Issue)
        issue(s)
      elsif s.is_a?(Enumerable) && s[0].is_a?(Issue)
        issues(s)
      else
        all
      end
    }
    scope :period, ->(period) {
      where({ table_name.to_sym => { created_at: period }})
    }
    scope :user_count, -> {
      group(:entry_id).order("count_user_id DESC").count("user_id")
    }
    scope :locale, ->(locale) {
      joins(:user).where({ users: { locale: locale} }) if locale.present?
    }
    scope :feed, ->(feed) {
      joins(:entry).where(entries: { feed_id: feed.id })
    }
    scope :keyword, ->(keyword) {
      joins(entry: :keywords).where(keywords: { id: keyword.id })
    }
    scope :tag, ->(tag) {
      joins(entry: :tags).where(tags: { id: tag.id })
    }
    scope :topic, ->(topic) {
      joins(entry: { feed: :topics }).where(topics: { id: topic.id })
    }
    scope :category, ->(category) {
      joins(entry: { feed: { subscriptions: :categories }})
        .where(categories: { id: category.id })
    }
    scope :issue, ->(issue) {
      joins(entry: :issues).where(issues: { id: issue.id })
    }
  end

  class_methods do
    def marker_params(user, id, _)
      {
        user:     user,
        entry_id: id,
      }
    end

    def mark_has_many_options
      { dependent: :destroy }
    end
  end
end
