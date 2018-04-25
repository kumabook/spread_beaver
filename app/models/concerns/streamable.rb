# frozen_string_literal: true
module Streamable
  extend ActiveSupport::Concern

  included do
    scope :stream, -> (s) {
      if s.is_a?(Feed)
        feed(s)
      elsif s.is_a?(Keyword)
        keyword(s)
      elsif s.is_a?(Tag)
        tag(s)
      elsif s.is_a?(Topic)
        topic(s)
      elsif s.is_a?(Category)
        category(s)
      elsif s.is_a?(Issue)
        issue(s)
      elsif s.is_a?(Enumerable) && s[0].is_a?(Issue)
        issues(s)
      else
        all
      end
    }
  end
end
