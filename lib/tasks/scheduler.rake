# coding: utf-8
require 'slack'

desc "Crawl sites of feeds and collect latest entries"
task :crawl => :environment do
  Rails.logger.info("Start crawling with feedly api...")
  notify_slack "Start crawling with feedly api..."
  results = Feed.fetch_all_latest_entries
  message = "Successfully crawling\n"
  message += results.select {|f|
    f[:entries].present?
  }.map { |f|
    "Create #{f[:entries].count} entries and #{f[:tracks].count} tracks from #{f[:feed].id}" }.join("\n")

  Rails.logger.info("Finish crawling.")

  Rails.logger.info("Clearing cache entries...")
  Topic.all.each do |topic|
    topic.delete_cache_entries
    topic.delete_cache_mix_entries
  end
  User.delete_cache_of_entries_of_all_user

  Rails.logger.info message
  notify_slack message

  if Feed::crawler_type == :feedlr
    Rails.logger.info("Updating entry visual...")
    Entry.update_visuals
    Rails.logger.info("Updated entry visual.")
  end
  Rails.logger.info("Finish!")
end

desc "Crawl playlists"
task :crawl_playlists => :environment do
  Rails.logger.info("Start crawling playlists")

  info = Playlist.crawl

  Rails.logger.info("Finish crawling playlists")
  Rails.logger.info("#{info[:total_tracks]} tracks from #{info[:total_playlists]}")
end

desc "Create latest entries as daily top keyword"
task :create_daily_issue => :environment do
  issues = Journal.create_daily_issues
  labels = issues.map {|i| "#{i.journal.label}-#{i.label}" }.join(" ")
  notify_slack "Successfully create daily issues: #{labels}"
end
