# frozen_string_literal: true
require "pink_spider"

task set_track_properties: :environment do
  batch_size = 100
  pink_spider = PinkSpider.new
  Track.where(provider: nil).find_in_batches(batch_size: batch_size) do |items|
    tracks = pink_spider.fetch_tracks(items.map(&:id))
    items.each do |item|
      t = tracks.find { |track| track["id"] == item.id }
      item.update_columns(title: t["title"], provider: t["provider"])
      puts "update track #{t['title']} #{t['id']}"
    end
  end

  Album.where(provider: nil).find_in_batches(batch_size: batch_size) do |items|
    albums = pink_spider.fetch_albums(items.map(&:id))
    items.each do |item|
      a = albums.find { |album| album["id"] == item.id }
      item.update_columns(title: a["title"], provider: a["provider"])
      puts "update album #{a['title']} #{a['id']}"
    end
  end

  Playlist.where(provider: nil).find_in_batches(batch_size: batch_size) do |items|
    playlists = pink_spider.fetch_playlists(items.map(&:id))
    items.each do |item|
      pl = playlists.find { |playlist| playlist["id"] == item.id }
      item.update_columns(title:  pl["title"], provider: pl["provider"])
      puts "update playlist #{pl['title']} #{pl['id']}"
    end
  end
end
