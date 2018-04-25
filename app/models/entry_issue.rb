# frozen_string_literal: true
class EntryIssue < ApplicationRecord
  belongs_to :entry
  belongs_to :issue, touch: true
end
