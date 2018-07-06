# frozen_string_literal: true

module SavableController
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  def save
    mark(:save_class)
  end

  def unsave
    unmark(:save_class)
  end

  module ClassMethods
  end
end
