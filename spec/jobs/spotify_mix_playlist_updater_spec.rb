# frozen_string_literal: true

require "rails_helper"

describe "SpotifyMixPlaylistUpdater" do
  let(:user) { FactoryBot.create(:admin) }
  let(:mix_topic) { FactoryBot.create(:mix) }

  let(:auth) {
    {
      user_id:  user.id,
      provider: "spotify",
      uid:      "typica.jp",
      credentials: "{}",
      raw_info: "{}",
    }
  }
  before(:each) do
    mock_up_pink_spider
    Authentication.create! auth
  end

  describe "#perform" do
    it do
      playlist = object_double(RSpotify::Playlist.new({ "tracks" => {} }))
      allow_any_instance_of(RSpotify::User).to receive(:create_playlist!) { playlist }
      allow_any_instance_of(RSpotify::User).to receive(:playlists) { [] }
      expect(playlist).to receive(:tracks) { [] }
      expect(playlist).to receive(:remove_tracks!)
      expect(playlist).to receive(:add_tracks!)
      allow(playlist).to receive(:name) { "name" }
      result = SpotifyMixPlaylistUpdater.perform_now(user.email, mix_topic.id)
      expect(playlist).to be(result)
    end
  end
end
