require 'pink_spider_helper'

module PinkSpiderMacros
  def mock_up_pink_spider
    track    = PinkSpiderHelper::track_hash
    album    = PinkSpiderHelper::album_hash
    playlist = PinkSpiderHelper::playlist_hash

    allow_any_instance_of(PinkSpider).to receive(:fetch_entries_of_feed) do
      {
        page:     0,
        per_page: 1,
        total:    1,
        items:    [PinkSpiderHelper::entry_hash(url: 'http://example.com/entry1')]
      }.with_indifferent_access
    end

    allow_any_instance_of(PinkSpider).to receive(:playlistify) do
      PinkSpiderHelper.entry_hash
    end

    allow_any_instance_of(PinkSpider).to receive(:fetch_track) do |this, id|
      track["id"] = id
      track
    end
    allow_any_instance_of(PinkSpider).to receive(:fetch_tracks) do |this, ids|
      ids.map {|id|
        track["id"] = id
        track.clone
      }
    end
    allow_any_instance_of(PinkSpider).to receive(:create_track) do |this|
      PinkSpiderHelper::track_hash
    end

    allow_any_instance_of(PinkSpider).to receive(:fetch_album) do |this, id|
      album["id"] = id
      album.clone
    end
    allow_any_instance_of(PinkSpider).to receive(:fetch_albums) do |this, ids|
      ids.map {|id|
        album["id"] = id
        album.clone
      }
    end
    allow_any_instance_of(PinkSpider).to receive(:create_album) do |this|
      PinkSpiderHelper::album_hash
    end

    allow_any_instance_of(PinkSpider).to receive(:fetch_playlist) do |this, id|
      playlist["id"] = id
      playlist
    end
    allow_any_instance_of(PinkSpider).to receive(:fetch_playlists) do |this, ids|
      ids.map {|id|
        playlist["id"] = id
        playlist.clone
      }
    end
    allow_any_instance_of(PinkSpider).to receive(:create_playlist) do |this|
      PinkSpiderHelper::playlist_hash
    end
  end
end
