class SubscriptionCategory < ApplicationRecord
  belongs_to :subscription
  belongs_to :category
end
