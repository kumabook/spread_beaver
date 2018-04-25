# frozen_string_literal: true
class Journal < ApplicationRecord
  has_many :issues, dependent: :destroy
  self.primary_key = :id

  after_initialize :set_stream_id, if: :new_record?
  before_save      :set_stream_id

  scope :stream_id, ->  (stream_id) {
    where(stream_id: stream_id)
  }

  def as_json(options = {})
    h = super(options)
    h["id"] = stream_id
    h.delete("stream_id")
    h
  end

  def topic
    Topic.find_by(id: "topic/#{label}")
  end

  def self.create_topic_mix_journal(topic)
    Journal.find_or_create_by(label: "mixes_#{topic.id}")
  end

  def self.topic_mix_journal(topic)
    Journal.find_by(label: "mixes_#{topic.id}")
  end

  def self.create_daily_issues
    Journal.all.select {|j| j.topic.present? }.map(&:create_daily_issue)
  end

  def create_daily_issue(date=Time.now)
    date_str = "#{date.strftime('%Y%m%d')}"
    issue = Issue.find_or_create_by(journal_id: id, label: date_str) do |i|
      i.description = "#{label} entries at #{date_str}"
    end
    issue.collect_entries_of_topic(topic) if topic.present?
    issue
  end

  def current_issue
    issues.order(label: :desc)
          .where(state: Issue.states[:published])
          .first
  end

  def entries_of_stream(page: 1, per_page: nil, since: nil)
    Entry.page(page).per(per_page).issue(current_issue)
  end

  private
  def set_stream_id
    self.stream_id = "journal/#{label}"
  end
end
