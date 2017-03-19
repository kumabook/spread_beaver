desc "This task is called by the Heroku scheduler add-on"
task :recrawl => :environment do
  Rails.logger.info("Start recrawling with pink-spider api")

  Entry.find_each do |entry|
    begin
      playlistified_entry = entry.playlistify(force: true)
    rescue
      Rails.logger.info("Entry #{entry.id} no longer exist")
      next
    end
    if playlistified_entry.visual_url.present?
      entry.visual = {
        url: playlistified_entry.visual_url,
        processor: "pink-spider-v1"
      }.to_json
      Rails.logger.info("Update visual of entry #{entry.id} with #{playlistified_entry.visual_url}")
      entry.save
    end
    Track.create_items_of(entry, playlistified_entry.tracks)
  end

  Rails.logger.info("Finish recrawling.")
end
