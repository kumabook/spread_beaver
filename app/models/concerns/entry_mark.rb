module EntryMark
  extend ActiveSupport::Concern
  included do
    scope :period, -> (period) {
      where({ table_name.to_sym => { created_at: period }})
    }
    scope :user_count, -> {
      group(:entry_id).order('count_user_id DESC').count('user_id')
    }
    scope :locale, -> (locale) {
      joins(:user).where({ users: { locale: locale} }) if locale.present?
    }
    scope :feed, -> (feed) {
      joins(:entry).where(entries: { feed_id: feed.id })
    }
    scope :keyword, -> (keyword) {
      joins(entry: :keywords).where(keywords: { id: keyword.id })
    }
    scope :tag, -> (tag) {
      joins(entry: :tags).where(tags: { id: tag.id })
    }
    scope :topic, -> (topic) {
      joins(entry: { feed: :topics }).where(topics: { id: topic.id })
    }
    scope :category, -> (category) {
      joins(entry: { feed: { subscriptions: :categories }})
        .where(categories: { id: category.id })
    }
    scope :issue, -> (issue) {
      joins(entry: :issues).where(issues: { id: issue.id })
    }
    scope :stream, -> (s) {
      if s.kind_of?(Feed)
        feed(s)
      elsif s.kind_of?(Keyword)
        keyword(s)
      elsif s.kind_of?(Tag)
        tag(s)
      elsif s.kind_of?(Topic)
        topic(s)
      elsif s.kind_of?(Category)
        category(s)
      elsif s.kind_of?(Issue)
        issue(s)
      else
        raise Exception.new("Unknown stream")
      end
    }
  end

  class_methods do
  end
end
