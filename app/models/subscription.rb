class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed
  has_many   :subscription_categories, dependent: :destroy
  has_many   :categories             , through: :subscription_categories
end
