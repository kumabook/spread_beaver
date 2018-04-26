# frozen_string_literal: true

class ReadEntry < ApplicationRecord
  include EntryMark
  belongs_to :user
  belongs_to :entry, counter_cache: :read_count, touch: true
end
