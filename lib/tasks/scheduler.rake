# coding: utf-8
require 'slack'

desc "Crawl sites of feeds and collect latest entries"
task :crawl => :environment do
  puts "Start crawling with feedly api..."
  notify_slack "Start crawling with feedly api..."
  results = Feed.fetch_all_latest_entries
  message = "Successfully crawling\n"
  message += results.map { |f|
    "Create #{f[:entries].count} entries and #{f[:tracks].count} tracks from #{f[:feed].id}"
  }.join("\n")
  notify_slack message
  puts "Finish crawling."

  Entry.update_visuals

  Topic.all.each do |topic|
    topic.delete_cache_entries
    topic.delete_cache_mix_entries
  end
end

desc "Create latest entries as daily top keyword"
task :create_daily_issue => :environment do
  Journal.find_each do |journal|
    journal.create_daily_issue
  end
  notify_slack "Successfully create daily issues of journals"
end
