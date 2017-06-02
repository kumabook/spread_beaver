require 'rails_helper'

RSpec.describe "Track Stream api", type: :request, autodoc: true do
  context 'after login' do
    before(:all) do
      setup()
      login()
      @feed         = FactoryGirl.create(:feed)
      @subscribed   = FactoryGirl.create(:feed)
      @keyword      = FactoryGirl.create(:keyword)
      @topic        = FactoryGirl.create(:topic)

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
        d = (n * 150).days.ago
        SavedEnclosure.create! user:           @user,
                               enclosure:      @feed.entries[0].tracks[n],
                               enclosure_type: Track.name,
                               created_at:     d
        LikedEnclosure.create! user:           @user,
                               enclosure:      @feed.entries[0].tracks[n],
                               enclosure_type: Track.name,
                               created_at:     d
        PlayedEnclosure.create! user:           @user,
                                enclosure:      @feed.entries[0].tracks[n],
                                enclosure_type: Track.name,
                                created_at:     d
      }
    end

    it "gets latest tracks with pagination" do
      resource = CGI.escape "playlist/global.latest"
      since    = 3.days.ago.to_time
      per_page = Track.latest(since).count / 2
      get "/v3/streams/#{resource}/tracks/contents",
          params: { count: per_page, newer_than: since.to_i * 1000 },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(per_page)
      expect(result['continuation']).not_to be_nil

      get "/v3/streams/#{resource}/tracks/contents",
          params: { continuation: result['continuation'] },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(per_page)
      expect(result['continuation']).to be_nil
    end

    it "gets popular tracks" do
      resource = CGI.escape "playlist/global.popular"
      get "/v3/streams/#{resource}/tracks/contents",
          params: {
            newer_than: 200.days.ago.to_time.to_i * 1000,
            older_than: Time.now.to_i * 1000
          },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(1)
      expect(result['continuation']).to be_nil
    end

    it "gets hot tracks" do
      resource = CGI.escape "playlist/global.hot"
      get "/v3/streams/#{resource}/tracks/contents",
          params: {
            newer_than: 200.days.ago.to_time.to_i * 1000,
            older_than: Time.now.to_i * 1000
          },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(1)
      expect(result['continuation']).to be_nil
    end

    it "gets featured tracks" do
      resource = CGI.escape "playlist/global.featured"
      get "/v3/streams/#{resource}/tracks/contents",
          params: {
            newer_than: 200.days.ago.to_time.to_i * 1000,
            older_than: Time.now.to_i * 1000
          },
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(PER_PAGE)
      expect(result['continuation']).not_to be_nil
    end

    it "gets liked tracks" do
      resource = CGI.escape "user/#{@user.id}/playlist/global.liked"
      get "/v3/streams/#{resource}/tracks/contents",
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(ITEM_NUM)
      expect(result['continuation']).to be_nil
    end

    it "gets saved tracks" do
      resource = CGI.escape "user/#{@user.id}/playlist/global.saved"
      get "/v3/streams/#{resource}/tracks/contents",
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(ITEM_NUM)
      expect(result['continuation']).to be_nil
    end

    it "gets played tracks" do
      resource = CGI.escape "user/#{@user.id}/playlist/global.played"
      get "/v3/streams/#{resource}/tracks/contents",
          headers: headers_for_login_user_api
      result = JSON.parse @response.body
      expect(result['items'].count).to eq(ITEM_NUM)
      expect(result['continuation']).to be_nil
    end

    context "legacy_user" do
      it "gets only legacy tracks" do
        resource = CGI.escape "user/#{@user.id}/playlist/global.liked"
        get "/v3/streams/#{resource}/tracks/contents",
            headers: headers_for_legacy_login_user_api
        result = JSON.parse @response.body
        expect(result['items'].count).to eq(0)
        expect(result['continuation']).to be_nil
      end
    end

    context "feed" do
      before do
        get "/v3/streams/#{@feed.escape.id}/tracks/contents",
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end

    context "keyword" do
      before do
        get "/v3/streams/#{@keyword.escape.id}/tracks/contents",
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end

    context "tag" do
      before do
        get "/v3/streams/#{@tag.escape.id}/tracks/contents",
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end

    context "category" do
      before do
        get "/v3/streams/#{@category.escape.id}/tracks/contents",
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end

    context "issue" do
      before do
        get "/v3/streams/#{CGI.escape @journal.stream_id}/tracks/contents",
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end
  end
end
