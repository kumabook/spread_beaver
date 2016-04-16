class FeedTopic < ActiveRecord::Base
  belongs_to :feed
  belongs_to :topic
end
