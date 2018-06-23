# frozen_string_literal: true

task divide_enclosures: :environment do
  Rails.logger.info("Divide_enclosures")
  count = Enclosure.count
  i = 0
  Enclosure.find_each do |enc|
    Rails.logger.info("[#{i}/#{count}] handle #{enc.type} #{enc.provider} #{enc.title}")
    case enc.type
    when "Track"
      Track.create!(enc.as_json(except: "type"))
    when "Album"
      Album.create!(enc.as_json(except: %w[type pick_count]))
    when "Playlist"
      Playlist.create!(enc.as_json(except: %w[type pick_count]))
    end
    i += 1
  end
end
