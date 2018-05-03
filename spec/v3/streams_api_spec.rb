# frozen_string_literal: true
require "rails_helper"


RSpec.describe "Streams api", type: :request, autodoc: true do
  context "after login" do
    before(:all) do
      setup()
      login()
      @feed         = FactoryBot.create(:feed)
      @subscribed   = FactoryBot.create(:feed)
      @keyword      = FactoryBot.create(:keyword)
      @topic        = FactoryBot.create(:topic)
      @feed.topics  = [@topic]
      @subscription = Subscription.create! user: @user,
                                           feed: @subscribed
      @category     = Category.create! subscriptions: [@subscription],
                                               label: "category",
                                               user: @user
      @tag          = Tag.create! user: @user,
                                  label: "tag",
                                  entries: @feed.entries
      @keyword.update! entries: @feed.entries
      @journal      = Journal.create!(label: "highlight")
      @issue        = Issue.create!(label: "1",
                                    state: Issue.states[:published],
                               journal_id: @journal.id)
      (0...ITEM_NUM).to_a.each { |n|
        LikedEntry.create! user: @user,
                           entry: @feed.entries[n],
                           created_at: 1.days.ago
      }
      (0...ITEM_NUM).to_a.each { |n|
        SavedEntry.create! user: @user,
                           entry: @feed.entries[n],
                           created_at: 1.days.ago
      }
      (0...ITEM_NUM).to_a.each { |n|
        ReadEntry.create! user: @user,
                          entry: @feed.entries[n],
                          created_at: 1.days.ago
      }
      (0...ITEM_NUM).to_a.each { |n|
        LikedEnclosure.create! user: @user,
                               enclosure: @subscribed.entries[0].tracks[n]
        LikedEnclosure.create! user: @user,
                               enclosure: @feed.entries[0].tracks[n]
      }
    end

    it "gets a first per_page entries of a feed" do
      get "/v3/streams/#{@feed.escape.id}/contents",
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(PER_PAGE)
      expect(result["continuation"]).not_to be_nil
    end

    it "gets a specified page entries of a feed" do
      continuation = V3::StreamsController::continuation(2, PER_PAGE)
      get "/v3/streams/#{@feed.escape.id}/contents",
          params: {continuation: continuation},
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(ENTRY_PER_FEED - PER_PAGE)
      expect(result["items"][0]["enclosure"].count).to eq(12)
      expect(result["continuation"]).to be_nil
    end

    it "gets entries of all subscirptions" do
      resource = CGI.escape "user/#{@user.id}/category/global.all"
      get "/v3/streams/#{resource}/contents",
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(PER_PAGE)
      result["items"].each { |item|
        expect(item["feed_id"]).to eq(@subscribed.id)
      }
      expect(result["continuation"]).not_to be_nil
    end

    it "gets saved entries" do
      resource = CGI.escape "user/#{@user.id}/tag/global.saved"
      get "/v3/streams/#{resource}/contents",
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(ITEM_NUM)
      expect(result["continuation"]).to be_nil
    end

    it "gets liked entries" do
      resource = CGI.escape "user/#{@user.id}/tag/global.liked"
      get "/v3/streams/#{resource}/contents",
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(ITEM_NUM)
      expect(result["continuation"]).to be_nil
    end

    it "gets read entries" do
      resource = CGI.escape "user/#{@user.id}/tag/global.read"
      get "/v3/streams/#{resource}/contents",
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(ITEM_NUM)
      expect(result["continuation"]).to be_nil
    end

    it "gets latest entries" do
      resource = CGI.escape "tag/global.latest"
      get "/v3/streams/#{resource}/contents",
          params: { newerThan: 3.days.ago.to_time.to_i * 1000 },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(2)
      expect(result["continuation"]).to be_nil
    end

    it "gets hot entries" do
      resource = CGI.escape "tag/global.hot"
      get "/v3/streams/#{resource}/contents",
          params: {
            newerThan: 200.days.ago.to_time.to_i * 1000,
            olderThan: Time.now.to_i * 1000
          },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(2)
      expect(result["continuation"]).to be_nil
    end

    it "gets popular entries" do
      resource = CGI.escape "tag/global.popular"
      get "/v3/streams/#{resource}/contents",
          params: {
            newerThan: 200.days.ago.to_time.to_i * 1000,
            olderThan: Time.now.to_i * 1000
          },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(2)
      expect(result["continuation"]).to be_nil
    end

    it "gets entries of a keyword" do
      resource = CGI.escape @keyword.id
      get "/v3/streams/#{resource}/contents",
          params: {
            newerThan: 200.days.ago.to_time.to_i * 1000,
            olderThan: Time.now.to_i * 1000
          },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(PER_PAGE)
    end

    it "gets entries of a tag" do
      resource = CGI.escape @tag.id
      get "/v3/streams/#{resource}/contents",
          params: {
            newerThan: 200.days.ago.to_time.to_i * 1000,
            olderThan: Time.now.to_i * 1000
          },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(PER_PAGE)
    end

    it "gets entries of feeds that has a specified topic " do
      resource = CGI.escape @topic.id
      get "/v3/streams/#{resource}/contents",
          params: {
            newerThan: 200.days.ago.to_time.to_i * 1000,
            olderThan: Time.now.to_i * 1000,
            count: 2
          },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(2)
      result["items"].each { |item|
        expect(Entry.find(item["id"]).feed).to eq(@feed)
      }
    end

    it "gets entries of feeds that has a specified category" do
      resource = CGI.escape @category.id
      get "/v3/streams/#{resource}/contents",
          params: {
            newerThan: 200.days.ago.to_time.to_i * 1000,
            olderThan: Time.now.to_i * 1000
          },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result["items"].count).to eq(PER_PAGE)
      result["items"].each { |item|
        expect(Entry.find(item["id"]).feed).to eq(@subscription.feed)
      }
    end

    context "legacy_user" do
      it "gets entries that includes only legacy tracks" do
        get "/v3/streams/#{@feed.escape.id}/contents",
            headers: headers_for_legacy_login_user_api
        result = JSON.parse @response.body
        expect(result["items"].count).to eq(PER_PAGE)
        expect(result["items"][0]["enclosure"].count).to eq(0)
        expect(result["continuation"]).not_to be_nil
      end
    end

    context "invalid stream_id" do
      it "returns not_found" do
        get "/v3/streams/#{CGI.escape("tag/global.invalid")}/contents",
            headers: headers_for_login_user_api
        expect(@response.status).to eq(404)
      end
    end

    context "feed" do
      before do
        get "/v3/streams/#{@feed.escape.id}/contents",
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end

    context "keyword" do
      before do
        get "/v3/streams/#{@keyword.escape.id}/contents",
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end

    context "tag" do
      before do
        get "/v3/streams/#{@tag.escape.id}/contents",
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end

    context "category" do
      before do
        get "/v3/streams/#{@category.escape.id}/contents",
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end

    context "issue" do
      before do
        get "/v3/streams/#{CGI.escape @journal.stream_id}/contents",
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end
  end
end
