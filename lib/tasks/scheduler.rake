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

  if Feed::USE_FEEDLR
    Rails.logger.info("Updating entry visual...")
    Entry.update_visuals
    Rails.logger.info("Updated entry visual.")
  end
  Rails.logger.info("Finish!")
end

desc "Create latest entries as daily top keyword"
task :create_daily_issue => :environment do
  Journal.find_each do |journal|
    journal.create_daily_issue
  end
  notify_slack "Successfully create daily issues of journals"
end
