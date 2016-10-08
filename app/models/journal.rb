class Journal < ActiveRecord::Base
  has_many :issues
  self.primary_key = :id

  after_initialize :set_stream_id, if: :new_record?
  before_save      :set_stream_id


  def create_daily_issue(date=Time.now.tomorrow)
    date_str = "#{date.strftime('%Y%m%d')}"
    issue = Issue.find_or_create_by(journal_id: id, label: date_str) do |issue|
      issue.description = "#{label} entries at #{date_str}"
    end
    topic = Topic.find_by(id: "topic/#{label}")
    issue.create_daily_issue_of_topic(topic) if topic.present?
  end

  def current_issue
    issues.order(label: :desc)
          .where(state: Issue.states[:published])
          .first
  end

  private
  def set_stream_id
    self.stream_id = "journal/#{label}"
  end
end
