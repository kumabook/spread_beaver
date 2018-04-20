module Streamable
  extend ActiveSupport::Concern

  included do
    scope :stream, -> (s) {
      if s.kind_of?(Feed)
        feed(s)
      elsif s.kind_of?(Keyword)
        keyword(s)
      elsif s.kind_of?(Tag)
        tag(s)
      elsif s.kind_of?(Topic)
        topic(s)
      elsif s.kind_of?(Category)
        category(s)
      elsif s.kind_of?(Issue)
        issue(s)
      elsif s.kind_of?(Enumerable) && s[0].kind_of?(Issue)
        issues(s)
      else
        all
      end
    }
  end
end
