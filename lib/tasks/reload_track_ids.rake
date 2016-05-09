desc "This task is called by the Heroku scheduler add-on"
task :reload_track_ids => :environment do
  puts "Reload track ids of #{Track.all.count} tracks"

  i = 0
  Track.find_each do |track|
    identifier = track.identifier
    track.identifier.match /[a-zA-Z0-9\-\_]+/ do |md|
      if identifier != md[0]
        puts "Normalize #{identifier} -> #{md[0]}"
        identifier = md[0]
      end
    end
    api_url = "http://pink-spider.herokuapp.com/tracks/#{track.provider}/#{identifier}"
    likes        = track.likes
    entry_tracks = track.entry_tracks
    begin
      response = RestClient.get api_url, params: {}, :accept => :json
    rescue Exception => e
      p "errpr at #{api_url}"
      p e
      return
    end
    if response.code != 200
      puts "error at #{api_url}"
      return
    end
    hash = JSON.parse(response)

    puts "#{i} #{track.provider}/#{track.identifier}: rename #{track.id} -> #{hash['id']}"
    likes.each        {        |like|        like.update! track_id: hash["id"] }
    entry_tracks.each { |entry_track| entry_track.update! track_id: hash["id"] }
    track.update! id: hash["id"], identifier: identifier
    i += 1
  end
  puts "Finish reloading track ids"
end
