class SubscriptionCategory < ActiveRecord::Base
  belongs_to :subscription
  belongs_to :category
end
