# frozen_string_literal: true

require "rails_helper"

describe "PlaylistUpdater" do
  let(:user) { FactoryBot.create(:admin) }
  let(:topic) { Topic.create!(label: "topic", description: "desc") }
  let (:track) { FactoryBot.create(:track) }
  let (:playlist) { FactoryBot.create(:playlist) }
  let (:today) { Time.now.beginning_of_day }

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
    authentication = Authentication.create! auth
    Pick.create!(enclosure_id:   track.id,
                 enclosure_type: Track.name,
                 container_id:   playlist.id,
                 container_type: Playlist.name,
                 created_at:     today,
                 updated_at:     today)
    topic_mix_journal = Journal.create_topic_mix_journal(topic)
    issue = topic.find_or_create_mix_issue(topic_mix_journal)
    issue.playlists << playlist
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
      email = Setting.spotify_playlist_owner_email
      result = PlaylistUpdater.perform_now(user.email, topic.id)
      expect(playlist).to be(result)
    end
  end
end
