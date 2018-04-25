# frozen_string_literal: true
module LikableController
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  def model_class
    controller_name.classify.constantize
  end

  def like
    mark(:like_class)
  end

  def unlike
    unmark(:like_class)
  end

  module ClassMethods
  end
end
