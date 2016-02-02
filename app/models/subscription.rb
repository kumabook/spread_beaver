class Subscription < ActiveRecord::Base
  belongs_to :user
  has_one    :feed
end
