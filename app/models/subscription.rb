class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :feed
  has_many   :subscription_categories, dependent: :destroy
  has_many   :categories             , through: :subscription_categories

  after_save    :delete_cache_of_subscriptions
  after_destroy :delete_cache_of_subscriptions

  def self.of(user)
    Rails.cache.fetch("subscriptions_of_user-#{user.id}") do
      user.subscriptions.to_a
    end
  end

  def delete_cache_of_subscriptions
    Rails.cache.delete_matched("subscriptions_of_user-#{user.id}")
    User.delete_cache_of_stream(user.stream_id)
  end
end
