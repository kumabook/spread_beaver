# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Playlist Stream api", type: :request, autodoc: true do
  context "after login" do
    before(:all) do
      setup()
      login()
      @feed    = FactoryBot.create(:feed)
      (0...ITEM_NUM).to_a.each { |n|
        d = (n * 150).days.ago
        SavedEnclosure.create! user:           @user,
                               enclosure:      @feed.entries[0].playlists[n],
                               enclosure_type: Playlist.name,
                               created_at:     d
        LikedEnclosure.create! user:           @user,
                               enclosure:      @feed.entries[0].playlists[n],
                               enclosure_type: Playlist.name,
                               created_at:     d
        PlayedEnclosure.create! user:           @user,
                                enclosure:      @feed.entries[0].playlists[n],
                                enclosure_type: Playlist.name,
                                created_at:     d
      }
    end

    it "gets latest playlists with pagination" do
      resource = CGI.escape "tag/global.latest"
      get "/v3/streams/#{resource}/playlists/contents",
          params: { newer_than: 3.days.ago.to_time.to_i * 1000 },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(PER_PAGE)
      expect(result["continuation"]).not_to be_nil

      get "/v3/streams/#{resource}/playlists/contents",
          params: { continuation: result["continuation"] },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(Entry.all.count - PER_PAGE)
      expect(result["continuation"]).to be_nil
    end

    it "gets popular playlists" do
      resource = CGI.escape "tag/global.popular"
      get "/v3/streams/#{resource}/playlists/contents",
          params: {
            newer_than: 200.days.ago.to_time.to_i * 1000,
            older_than: Time.now.to_i * 1000
          },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(1)
      expect(result["continuation"]).to be_nil
    end

    it "gets hot playlists" do
      resource = CGI.escape "tag/global.hot"
      get "/v3/streams/#{resource}/playlists/contents",
          params: {
            newer_than: 200.days.ago.to_time.to_i * 1000,
            older_than: Time.now.to_i * 1000
          },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(1)
      expect(result["continuation"]).to be_nil
    end

    it "gets liked playlists" do
      resource = CGI.escape "user/#{@user.id}/tag/global.liked"
      get "/v3/streams/#{resource}/playlists/contents",
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(ITEM_NUM)
      expect(result["continuation"]).to be_nil
    end

    it "gets saved tracks" do
      resource = CGI.escape "user/#{@user.id}/tag/global.saved"
      get "/v3/streams/#{resource}/playlists/contents",
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(ITEM_NUM)
      expect(result["continuation"]).to be_nil
    end

    it "gets played tracks" do
      resource = CGI.escape "user/#{@user.id}/tag/global.played"
      get "/v3/streams/#{resource}/playlists/contents",
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(ITEM_NUM)
      expect(result["continuation"]).to be_nil
    end
  end
end
