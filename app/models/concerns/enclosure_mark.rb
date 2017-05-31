module EnclosureMark
  extend ActiveSupport::Concern
  included do
    scope :period, -> (period) {
      where({ table_name.to_sym => { created_at: period }})
    }
    scope :user_count, -> {
      group(:enclosure_id).order('count_user_id DESC').count('user_id')
    }
    scope :topic,      -> (topic)    {
      joins(enclosure: { entries: { feed: :topics }})
        .where(enclosures: { entries: { feed: { topics: { id: topic.id }}}})
    }
    scope :stream, -> (s) {
      if s.kind_of?(Topic)
        topic(s)
      else
        all
      end
    }
  end

  class_methods do
  end
end
