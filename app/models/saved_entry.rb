# frozen_string_literal: true
class SavedEntry < ApplicationRecord
  include EntryMark
  belongs_to :user
  belongs_to :entry, counter_cache: :saved_count, touch: true
end
