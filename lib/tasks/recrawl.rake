desc "This task is called by the Heroku scheduler add-on"
task :recrawl => :environment do
  puts "Start recrawling with pink-spider api"

  Entry.find_each do |entry|
    begin
      playlist = entry.fetch_playlist(force: true)
    rescue
      puts "Entry #{entry.id} no longer exist"
      next
    end
    if playlist.visual_url.present?
      entry.visual = {
        url: playlist.visual_url,
        processor: "pink-spider-v1"
      }.to_json
      puts "Update visual of entry #{entry.id} with #{playlist.visual_url}"
      entry.save
    end
    playlist.create_tracks
  end

  puts "Finish recrawling."
end
