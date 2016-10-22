class Issue < ActiveRecord::Base
  include Escapable
  enum state: { draft: 0, published: 1 }
  has_many :entry_issues, ->{order("entry_issues.engagement DESC")}, dependent: :destroy
  has_many :entries, through: :entry_issues
  belongs_to :journal

  after_touch  :delete_cache_entries
  after_update :delete_cache_entries

  self.primary_key = :id

  def stream_id
    "journal/#{journal.id}/#{label}"
  end

  def create_daily_issue_of_topic(date=Time.now, topic)
    entries = Entry.latest_entries_of_topic(topic)
                   .select { |entry| entry.has_visual? }
    if entries.empty?
      puts "Failed to create journal because there is no entry"
    end
    entries.each_with_index do |entry, i|
      ej = EntryIssue.find_or_create_by(entry_id: entry.id,
                                        issue_id: id)
      ej.update_attributes(engagement: (entries.count - i) * 10)
    end
    first_entry = entries.find {|e| e.tracks.count > 0 }
    first_entry = entries.first if first_entry.nil?
    first_ej    = EntryIssue.find_or_create_by(entry_id: first_entry.id,
                                               issue_id: id)
    first_ej.update_attributes(engagement: (entries.count + 1) * 10)
    puts "Add #{entries.count} entries to Create daily issue: #{label} #{journal.label}"
  end

  def delete_cache_entries
    Entry.delete_cache_of_stream(stream_id)
  end
end
