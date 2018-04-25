# frozen_string_literal: true
module ReadableController
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  def model_class
    controller_name.classify.constantize
  end

  def read
    mark(:read_class)
  end

  def unread
    unmark(:read_class)
  end

  module ClassMethods
  end
end
