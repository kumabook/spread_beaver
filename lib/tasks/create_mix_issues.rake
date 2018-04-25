# coding: utf-8
# frozen_string_literal: true
task :create_mix_issues => :environment do
  ids = [
    "topic/国内メディア",
    "topic/海外メディア",
  ]
  Topic.where(id: ids).each do |topic|
    entry = topic.find_or_create_dummy_entry
    mix_journal = Journal.create_topic_mix_journal(topic)
    issue = topic.find_or_create_mix_issue(mix_journal)
    entry.playlists.each do |playlist|
      begin
        issue.playlists << playlist
      rescue ActiveRecord::RecordNotUnique
      end
    end
    entry.feed.destroy
    entry.destroy
  end

  Entry.period(2.week.ago..Time.now).each do |entry|
    entry.feed.topics.each do |topic|
      mix_journal = topic.mix_journal
      if mix_journal.present?
        mix_issue = topic.find_or_create_daily_mix_issue(mix_journal, entry.created_at)
        entry.playlists.each do |playlist|
          begin
            mix_issue.playlists << playlist
          rescue ActiveRecord::RecordNotUnique
            # already exists
          end
        end
      end
    end
  end
end
