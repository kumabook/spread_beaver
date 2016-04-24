class Topic < ActiveRecord::Base
  include Escapable
  has_many :feeds, through: :feed_topics
  has_many :feed_topics

  self.primary_key = :id

  after_initialize :set_id, if: :new_record?
  before_save      :set_id

  private
  def set_id
    self.id = "topic/#{self.label}"
  end
end
