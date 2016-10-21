class FeedTopic < ActiveRecord::Base
  belongs_to :feed
  belongs_to :topic, touch: true
end
