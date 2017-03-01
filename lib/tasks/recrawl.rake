desc "This task is called by the Heroku scheduler add-on"
task :recrawl => :environment do
  puts "Start recrawling with pink-spider api"

  Entry.find_each do |entry|
    begin
      playlistified_entry = entry.playtified_entry(force: true)
    rescue
      puts "Entry #{entry.id} no longer exist"
      next
    end
    if playlistified_entry.visual_url.present?
      entry.visual = {
        url: playlistified_entry.visual_url,
        processor: "pink-spider-v1"
      }.to_json
      puts "Update visual of entry #{entry.id} with #{playlistified_entry.visual_url}"
      entry.save
    end
    playlistified_entry.create_tracks
  end

  puts "Finish recrawling."
end
