# coding: utf-8
require 'slack'

desc "Crawl sites of feeds and collect latest entries"
task :crawl, [:type]  => :environment do |_, args|

  args.with_defaults(type: "pink_spider")
  crawler_type = args[:type].to_sym

  Rails.logger.info("Start crawling...")
  notify_slack "Start crawling..."

  results = RSSCrawler.perform_now(crawler_type)
  message = RSSCrawler.build_message_from_results(results)

  Rails.logger.info("Finish crawling.")
  notify_slack "Finish crawling."

  Rails.logger.info("Clearing cache entries...")
  Topic.all.each do |topic|
    topic.delete_cache_entries
    topic.delete_cache_mix_entries
  end
  User.delete_cache_of_entries_of_all_user

  Rails.logger.info message
  notify_slack message

  if crawler_type == :feedlr
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
