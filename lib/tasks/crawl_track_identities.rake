# frozen_string_literal: true

task crawl_track_identities: :environment do
  Rails.logger.info("crawl_track_identities")
  Track.where(identity_id: nil, provider: ["Spotify", "AppleMusic"]).order(created_at: :desc).find_each do |track|
    puts "Crawling #{track.title}"
    identity = track.create_identity
    if identity.present?
      puts "Crawled #{track.title}: #{identity.id} is created"
    else
      puts "Crawled #{track.title}: no identity is created"
    end
  end
end
