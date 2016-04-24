module Escapable
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
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

  module ClassMethods
  end
end
