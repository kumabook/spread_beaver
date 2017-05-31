module EntryMark
  extend ActiveSupport::Concern
  included do
    scope :period, -> (period) {
      where({ table_name.to_sym => { created_at: period }})
    }
    scope :user_count, -> {
      group(:entry_id).order('count_user_id DESC').count('user_id')
    }
    scope :keyword, -> (keyword) {
      joins(entry: :keywords)
        .where(entries: { keywords: { id: keyword.id }})
    }
    scope :topic, -> (topic) {
      joins(entry: { feed: :topics })
        .where(entries: { feed: { topics: { id: topic.id }}})
    }
    scope :stream, -> (s) {
      if s.kind_of?(Topic)
        topic(s)
      elsif s.kind_of?(Keyword)
        keyword(s)
      else
        all
      end
    }
  end

  class_methods do
  end
end
