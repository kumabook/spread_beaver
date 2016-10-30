class Like < ApplicationRecord
  belongs_to :user
  belongs_to :track, counter_cache: :like_count, touch: true

  scope :period,     -> (from, to) { where("created_at >= ?", from).where("created_at <= ?", to) }
  scope :user_count, ->            { group(:track_id).order('count_user_id DESC').count('user_id') }
end
