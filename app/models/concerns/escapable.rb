module Escapable
  extend ActiveSupport::Concern
  included do
  end

  def escape
    clone = self.dup
    clone.id = CGI.escape self.id
    clone
  end

  def unescape
    clone = self.dup
    clone.id = CGI.unescape self.id
    clone
  end

  class_methods do
  end
end
