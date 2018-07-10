# frozen_string_literal: true

class Keywordable < ApplicationRecord
  belongs_to :keywordable, touch: true, polymorphic: true
  belongs_to :keyword
end
