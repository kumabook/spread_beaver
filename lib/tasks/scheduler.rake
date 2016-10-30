# coding: utf-8
desc "Crawl sites of feeds and collect latest entries"
task :crawl => :environment do
  puts "Start crawling with feedly api..."

  Feed.fetch_all_latest_entries
  Entry.update_visuals

  puts "Finish crawling."

  Topic.all.each do |topic|
    topic.delete_cache_of_stream
  end

  puts "Clear cache"
end

task :clear_cache => :environment do
  Rails.cache.delete_matched("*")
  puts "Clear cache"
end

desc "Create latest entries as daily top keyword"
task :create_daily_issue => :environment do
  Journal.find_each do |journal|
    journal.create_daily_issue
  end
end
