# frozen_string_literal: true

require "rails_helper"

describe EnclosuresController, type: :controller do
  let  (:uuid)    { SecureRandom.uuid }
  let! (:track)    { FactoryBot.create(:track) }
  let! (:playlist) { FactoryBot.create(:playlist) }
  let  (:user)    { FactoryBot.create(:admin) }

  before(:each) do
    login_user user
  end

  describe "#index" do
    before { get :index, params: { type: "Track" } }
    it { expect(assigns(:enclosures)).to eq([track])  }
    it { expect(response).to render_template("index") }
  end

  describe "#search" do
    before { get :search, params: { type: "Track", query: track.title } }
    it { expect(assigns(:enclosures)).to eq([track])  }
    it { expect(response).to render_template("index") }
  end

  describe "#new" do
    before { get :new, params: { type: "Track" } }
    it { expect(response).to render_template("new") }
  end

  describe "#create" do
    count = 0
    before do
      count = Track.count
      post :create, params: {
             type: "Track",
             track: {
               provider: "YouTube",
               identifier: "abcdefg"
             }
           }
    end
    it { expect(Track.count).to eq(count + 1) }
  end

  describe "#destroy" do
    before {
      delete :destroy, params: { id: track.id, type: Track.name }
    }
    it { expect(response).to redirect_to tracks_url }
    it { expect(Track.find_by(id: track.id)).to be_nil }
  end

  describe "#activate" do
    it {
      expect_any_instance_of(PinkSpider).to receive(:update_playlist)
      get :activate, params: { id: playlist.id, type: Playlist.name }
    }
  end

  describe "#deactivate" do
    it {
      expect_any_instance_of(PinkSpider).to receive(:update_playlist)
      get :deactivate, params: { id: playlist.id, type: Playlist.name }
    }
  end

  describe "#crawl" do
    it {
      expect_any_instance_of(PinkSpider).to receive(:fetch_tracks_of_playlist)
      get :crawl, params: { id: playlist.id, type: Playlist.name }
    }
  end

  describe "#like" do
    before do
      post :like, params: {
             type:     "Track",
             track_id: track.id,
           }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(LikedEnclosure.find_by(enclosure_id: track.id, user_id: user.id)).not_to be_nil }
  end

  describe "#unlike" do
    before do
      like = LikedEnclosure.create!(user_id:        user.id,
                                    enclosure_id:   track.id,
                                    enclosure_type: Track.name)
      delete :unlike, params: {
               type:     "Track",
               id:       like.id,
               track_id: track.id,
             }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(LikedEnclosure.find_by(enclosure_id: track.id, user_id: user.id)).to be_nil }
  end

  describe "#save" do
    before do
      post :save, params: {
             type:     "Track",
             track_id: track.id,
           }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(SavedEnclosure.find_by(enclosure_id: track.id, user_id: user.id)).not_to be_nil }
  end

  describe "#unsave" do
    before do
      save = SavedEnclosure.create!(user_id:        user.id,
                                    enclosure_id:   track.id,
                                    enclosure_type: Track.name)
      delete :unsave, params: {
               type:     "Track",
               id:       save.id,
               track_id: track.id,
             }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(SavedEnclosure.find_by(enclosure_id: track.id, user_id: user.id)).to be_nil }
  end

  describe "#play" do
    before do
      post :play, params: {
             type:     "Track",
             track_id: track.id,
           }
    end
    it { expect(response).to redirect_to tracks_url }
    it { expect(PlayedEnclosure.find_by(enclosure_id: track.id, user_id: user.id)).not_to be_nil }
  end
end
