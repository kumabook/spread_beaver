require "pink_spider"

class AddProviderToEnclosure < ActiveRecord::Migration[5.0]
  def up
    add_column :enclosures, :provider, :integer, default: 0
    add_column :enclosures, :title, :string, default: ""
    add_index :enclosures, :title, unique: false
    add_index :enclosures, :provider, unique: false

    batch_size = 100
    pink_spider = PinkSpider.new
    Track.all.find_in_batches(batch_size: batch_size) do |items|
      tracks = pink_spider.fetch_tracks(items.map {|i| i.id })
      items.each do |item|
        t = tracks.find {|track| track["id"] == item.id }
        item.update_columns(title: t["title"], provider: t["provider"])
        p "update #{t["title"]}"
      end
    end

    Album.all.find_in_batches(batch_size: batch_size) do |items|
      albums = pink_spider.fetch_albums(items.map {|i| i.id })
      items.each do |item|
        a = albums.find {|album| album["id"] == item.id }
        item.update_columns(title: a["title"], provider: a["provider"])
        p "update #{a["title"]}"
      end
    end

    Playlist.all.find_in_batches(batch_size: batch_size) do |items|
      playlists = pink_spider.fetch_playlists(items.map {|i| i.id })
      items.each do |item|
        pl = playlists.find {|playlist| playlist["id"] == item.id }
        item.update_columns(title:  pl["title"], provider: pl["provider"])
        p "update #{pl["title"]}"
      end
    end
  end

  def down
    remove_column :enclosures, :provider
  end
end
