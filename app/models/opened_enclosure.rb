class OpenedEnclosure < ApplicationRecord
  belongs_to :user
  belongs_to :enclosure, counter_cache: :opened_count, touch: true

  scope :period,     -> (from, to) { where("created_at >= ?", from).where("created_at <= ?", to) }
  scope :user_count, ->            { group(:enclosure_id).order('count_user_id DESC').count('user_id') }
end
