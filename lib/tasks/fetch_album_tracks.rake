# frozen_string_literal: true

task fetch_album_tracks: :environment do
  count = Album.count
  index = 0
  Album.all.find_each do |album|
    index += 1
    album.fetch_tracks
    puts "[#{index}/#{count}]"
  end
end
