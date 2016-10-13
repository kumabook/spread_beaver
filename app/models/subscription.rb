class Subscription < ActiveRecord::Base
  belongs_to :user                   , dependent: :destroy
  belongs_to :feed                   , dependent: :destroy
  has_many   :subscription_categories, dependent: :destroy
  has_many   :categories             , through: :subscription_categories
end
