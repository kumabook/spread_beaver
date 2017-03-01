# coding: utf-8
require 'rails_helper'

describe Track do
  let (:entries) { FactoryGirl.create(:feed).entries }
  let (:track  ) { entries[0].tracks[0] }
  before do
  end

  it { expect(track.track_likes.count).to eq(track.like_count) }
  it { expect(track.entry_tracks.count).to eq(track.entries_count) }

  context "when entry is deleted" do
    count = 0
    before do
      count = track.entries.count
      entries[0].destroy!
    end
    it { expect(track.entry_tracks.count).to eq(count - 1) }
  end
end
