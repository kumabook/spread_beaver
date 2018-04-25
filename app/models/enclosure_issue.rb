# frozen_string_literal: true
class EnclosureIssue < ApplicationRecord
  belongs_to :enclosure, polymorphic: true, touch: true
  belongs_to :issue, touch: true
end
