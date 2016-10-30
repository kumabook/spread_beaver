class FeedTopic < ApplicationRecord
  belongs_to :feed
  belongs_to :topic, touch: true
end
