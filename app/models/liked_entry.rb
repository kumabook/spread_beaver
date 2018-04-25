# frozen_string_literal: true
class LikedEntry < ApplicationRecord
  include EntryMark
  belongs_to :user
  belongs_to :entry, counter_cache: :likes_count, touch: true
end
