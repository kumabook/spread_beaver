# frozen_string_literal: true

module Escapable
  extend ActiveSupport::Concern
  included do
  end

  def escape
    clone = dup
    clone.id = CGI.escape id
    clone
  end

  def unescape
    clone = dup
    clone.id = CGI.unescape id
    clone
  end

  class_methods do
  end
end
