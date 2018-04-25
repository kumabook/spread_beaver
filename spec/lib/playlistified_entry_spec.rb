# coding: utf-8
# frozen_string_literal: true

require "pink_spider_helper"
require "playlistified_entry"

describe PlaylistifiedEntry do
  let (:entry_hash) {
    PinkSpiderHelper::entry_hash
  }
  let (:playlistified_entry) {
    e = entry_hash
    PlaylistifiedEntry.new(e[:id],
                           e[:url],
                           e[:title],
                           e[:description],
                           e[:visual_url],
                           e[:locale],
                           e[:tracks],
                           e[:playlists],
                           e[:albums],
                           e)
  }
  describe "#initialize" do
    it "should creates a instance" do
      e    = playlistified_entry
      hash = entry_hash
      expect(e.id         ).to eq(hash[:id])
      expect(e.url        ).to eq(hash[:url])
      expect(e.title      ).to eq(hash[:title])
      expect(e.description).to eq(hash[:description])
      expect(e.visual_url ).to eq(hash[:visual_url])
      expect(e.locale     ).to eq(hash[:locale])
      expect(e.tracks     ).to eq(hash[:tracks])
      expect(e.playlists  ).to eq(hash[:playlists])
      expect(e.albums     ).to eq(hash[:albums])
      expect(e.entry      ).to eq(hash)
    end
  end
end
