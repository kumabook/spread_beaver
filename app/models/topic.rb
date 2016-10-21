class Topic < ActiveRecord::Base
  include Escapable
  after_touch   :delete_cache_entries
  after_save    :delete_cache
  after_destroy :delete_cache

  has_many :feed_topics, dependent: :destroy
  has_many :feeds      , through: :feed_topics

  self.primary_key = :id

  after_initialize :set_id, if: :new_record?
  before_save      :set_id

  def delete_cache_entries
    Entry.delete_cache_of_stream(id)
  end

  def self.topics
    Rails.cache.fetch("topics") {
      Topic.order("engagement DESC").all.to_a
    }
  end

  private
  def set_id
    self.id = "topic/#{self.label}"
  end

  def delete_cache
    Topic.delete_cache
  end

  def self.delete_cache
    Rails.cache.delete("topics")
  end
end
