# frozen_string_literal: true

class SubscriptionCategory < ApplicationRecord
  belongs_to :subscription
  belongs_to :category
end
