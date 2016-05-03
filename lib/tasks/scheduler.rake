desc "This task is called by the Heroku scheduler add-on"
task :crawl => :environment do
  puts "Start crawling with feedly api..."

  Feed.fetch_all_latest_entries
  Entry.update_visuals

  puts "Finish crawling."
end
