# frozen_string_literal: true

module EnclosureMark
  extend ActiveSupport::Concern
  included do
    scope :stream, ->(s, clazz) {
      if s.is_a?(Feed)
        feed(s, clazz)
      elsif s.is_a?(Keyword)
        keyword(s, clazz)
      elsif s.is_a?(Tag)
        tag(s, clazz)
      elsif s.is_a?(Topic)
        topic(s, clazz)
      elsif s.is_a?(Category)
        category(s, clazz)
      elsif s.is_a?(Issue)
        issue(s, clazz)
      elsif s.is_a?(Enumerable) && s[0].is_a?(Issue)
        issues(s, clazz)
      else
        all
      end
    }
    scope :period, ->(period) {
      where({ table_name.to_sym => { created_at: period }})
    }
    scope :user_count, -> {
      group(:enclosure_id).order("count_user_id DESC").count("user_id")
    }
    scope :locale, ->(locale) {
      joins(:user).where({ users: { locale: locale} }) if locale.present?
    }
    scope :provider, ->(provider, clazz) {
      joins(clazz.name.downcase.to_sym).where(clazz.table_name.to_sym => { provider: provider }) if provider.present?
    }
  end

  class_methods do
    def include_stream_scopes
      scope :feed, ->(feed, clazz) {
        joins(clazz.name.downcase.to_sym => :entries).where(entries: { feed_id: feed.id })
      }
      scope :keyword, ->(keyword, clazz) {
        joins(clazz.name.downcase.to_sym => { entries: :keywords })
          .where(keywords: { id: keyword.id })
      }
      scope :tag, ->(tag, clazz) {
        joins(clazz.name.downcase.to_sym => { entries: :tags }).where(tags: { id: tag.id })
      }
      scope :topic,      ->(topic, clazz)    {
        joins(clazz.name.downcase.to_sym => { entries: { feed: :topics }})
          .where(topics: { id: topic.id })
      }
      scope :category, ->(category, clazz) {
        joins(clazz.name.downcase.to_sym => { entries: { feed: { subscriptions: :categories }}})
          .where(categories: { id: category.id })
      }
      scope :issue, ->(issue, clazz) {
        joins(clazz.name.downcase.to_sym => { entries: :issues }).where(issues: { id: issue.id })
      }
    end

    def marker_params(user, id, type=nil)
      {
        user:           user,
        enclosure_id:   id,
        enclosure_type: type,
      }
    end

    def mark_has_many_options
      { dependent: :destroy, as: :enclosure }
    end
  end
end
