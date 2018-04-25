# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Mixes api", type: :request, autodoc: true do
  context "after login" do
    before(:all) do
      setup()
      login()
      @feed         = FactoryBot.create(:feed)
      @topic        = FactoryBot.create(:topic)
      @feed.topics  = [@topic]
      @keyword      = Keyword.create!(label: "fujirock")
      @tag          = Tag.create!(label: "fujirock", user: @user)
      @subscription = Subscription.create!(feed: @feed, user: @user)
      @category     = Category.create!(label: "event", user: @user)
      @subscription.categories = [@category]
      @journal      = Journal.create!(label: "highlight")
      @issue         = Issue.create!(label: "1",
                                     state: Issue.states[:published],
                                journal_id: @journal.id)
      (0...ITEM_NUM).to_a.each { |n|
        LikedEntry.create! user: @user,
                           entry: @feed.entries[n],
                           created_at: 300.days.ago
      }
      (0...ITEM_NUM).to_a.each { |n|
        ReadEntry.create! user: @user,
                          entry: @feed.entries[n],
                          created_at: 100.days.ago
      }
      @en_user = FactoryBot.create(:member, :en)
      ReadEntry.create! user: @en_user,
                        entry: @feed.entries[0],
                        created_at: 100.days.ago
    end

    context "hot mix" do
      it "gets hot mixes of a topic " do
        get "/v3/mixes/#{@topic.escape.id}/contents",
            params: {
              type:      :hot,
              newerThan: 200.days.ago.to_time.to_i * 1000,
              olderThan: Time.now.to_i * 1000,
            },
            headers: headers_for_login_user_api
        result = JSON.parse @response.body
        expect(result["items"].count).to eq(ITEM_NUM)
        expect(result["continuation"]).to be_nil
      end

      it "doesn't count mark out of term" do
        get "/v3/mixes/#{@topic.escape.id}/contents",
            params: {
              type:      :hot,
              newerThan: 200.days.ago.to_time.to_i * 1000,
              olderThan: 150.days.ago.to_time.to_i * 1000,
            },
            headers: headers_for_login_user_api
        result = JSON.parse @response.body
        expect(result["items"].count).to eq(0)
        expect(result["continuation"]).to be_nil
      end
    end

    context "popular mix" do
      it "gets popular mixes of a topic " do
        get "/v3/mixes/#{@topic.escape.id}/contents",
            params: {
              type:      :popular,
              newerThan: 400.days.ago.to_time.to_i * 1000,
              olderThan: Time.now.to_i * 1000,
            },
            headers: headers_for_login_user_api
        result = JSON.parse @response.body
        expect(result["items"].count).to eq(ITEM_NUM)
        expect(result["continuation"]).to be_nil
      end

      it "doesn't count mark out of term" do
        get "/v3/mixes/#{@topic.escape.id}/contents",
            params: {
              type:      :popular,
              newerThan: 200.days.ago.to_time.to_i * 1000,
              olderThan: Time.now.to_i * 1000,
            },
            headers: headers_for_login_user_api
        result = JSON.parse @response.body
        expect(result["items"].count).to eq(0)
        expect(result["continuation"]).to be_nil
      end

      it "only counts mark with specified locale user  " do
        get "/v3/mixes/#{@topic.escape.id}/contents",
            params: {
              type:      :hot,
              locale:    "en",
              newerThan: 200.days.ago.to_time.to_i * 1000,
              olderThan: Time.now.to_i * 1000,
            },
            headers: headers_for_login_user_api
        result = JSON.parse @response.body
        expect(result["items"].count).to eq(1)
        expect(result["continuation"]).to be_nil
      end
    end

    context "feed" do
      before do
        get "/v3/mixes/#{@feed.escape.id}/contents",
            params: popular_params,
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end

    context "keyword" do
      before do
        get "/v3/mixes/#{@keyword.escape.id}/contents",
            params: popular_params,
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end

    context "tag" do
      before do
        get "/v3/mixes/#{@tag.escape.id}/contents",
            params: popular_params,
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end

    context "category" do
      before do
        get "/v3/mixes/#{@category.escape.id}/contents",
            params: popular_params,
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end

    context "issue" do
      before do
        get "/v3/mixes/#{CGI.escape @journal.stream_id}/contents",
            params: popular_params,
            headers: headers_for_login_user_api
      end
      it { expect(@response.status).to eq(200) }
    end
  end

  def popular_params
    {
      type:      :popular,
      newerThan: 200.days.ago.to_time.to_i * 1000,
      olderThan: Time.now.to_i * 1000,
    }
  end
end
