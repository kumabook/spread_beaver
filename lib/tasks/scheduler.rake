# coding: utf-8
require 'slack'

desc "Crawl sites of feeds and collect latest entries"
task :crawl => :environment do
  puts "Start crawling with feedly api..."
  notify_slack "Start crawling with feedly api..."
  results = Feed.fetch_all_latest_entries
  message = "Successfully crawling\n"
  message += results.select {|f|
    f[:entries].present?
  }.map { |f|
    "Create #{f[:entries].count} entries and #{f[:tracks].count} tracks from #{f[:feed].id}" }.join("\n")

  puts "Finish crawling."

  puts "Clearing cache entries..."
  Topic.all.each do |topic|
    topic.delete_cache_entries
    topic.delete_cache_mix_entries
  end
  User.delete_cache_of_entries_of_all_user

  notify_slack message

  puts "Updating entry visual..."
  Entry.update_visuals
  puts "Updated entry visual."
  puts "Finish!"
end

desc "Create latest entries as daily top keyword"
task :create_daily_issue => :environment do
  Journal.find_each do |journal|
    journal.create_daily_issue
  end
  notify_slack "Successfully create daily issues of journals"
end
