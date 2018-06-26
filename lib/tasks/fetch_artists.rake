# frozen_string_literal: true

require "pink_spider"

task fetch_artists: :environment do
  batch_size = 2000
  pink_spider = PinkSpider.new

  count = Track.count
  i     = 0
  Track.find_in_batches(batch_size: batch_size) do |items|
    tracks = pink_spider.fetch_tracks(items.map(&:id))
    items.each do |item|
      i += 1
      v = tracks.find { |track| track["id"] == item.id }
      item.update_by_content(v)
      item.save!
      v["artists"].each do |h|
        a = Artist.find_or_create_by(id: h["id"], name: h["name"], provider: h["provider"])
        EnclosureArtist.find_or_create_by(enclosure_id:   item.id,
                                          enclosure_type: Track.name,
                                          artist_id:      a.id)
      end
      puts "[#{i}/#{count}] Set artists of track #{v['title']} #{v['id']}"
    end
  end

  count = Track.count
  i     = 0
  Album.find_in_batches(batch_size: batch_size) do |items|
    albums = pink_spider.fetch_albums(items.map(&:id))
    items.each do |item|
      i += 1
      v = albums.find { |album| album["id"] == item.id }
      item.update_by_content(v)
      item.save!
      v["artists"].each do |h|
        a = Artist.find_or_create_by(id: h["id"], name: h["name"], provider: h["provider"])
        EnclosureArtist.find_or_create_by(enclosure_id:   item.id,
                                          enclosure_type: Album.name,
                                          artist_id:      a.id)
      end
      puts "[#{i}/#{count}}] Set artists of album #{v['title']} #{v['id']}"
    end
  end

  Playlist.find_in_batches(batch_size: batch_size) do |items|
    playlists = pink_spider.fetch_playlists(items.map(&:id))
    items.each do |item|
      i += 1
      v = playlists.find { |playlist| playlist["id"] == item.id }
      item.update_by_content(v)
      item.save!
      puts "[#{i}/#{count}}] Update playlist #{v['title']} #{v['id']}"
    end
  end
end
