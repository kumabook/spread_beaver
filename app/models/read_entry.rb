class ReadEntry < ApplicationRecord
  belongs_to :user
  belongs_to :entry, counter_cache: :read_count, touch: true

  scope :period,     -> (from, to) { where("created_at >= ?", from).where("created_at <= ?", to) }
  scope :user_count, ->            { group(:entry_id).order('count_user_id DESC').count('user_id') }
end
