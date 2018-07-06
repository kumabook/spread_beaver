# frozen_string_literal: true

module PlayableController
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  def play
    mark(:play_class)
  end

  module ClassMethods
  end
end
