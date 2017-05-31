require 'rails_helper'

RSpec.describe "Mixes api", type: :request, autodoc: true do
  context 'after login' do
    before(:all) do
      setup()
      login()
      @feed         = FactoryGirl.create(:feed)
      @topic        = FactoryGirl.create(:topic)
      @feed.topics  = [@topic]
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
        expect(result['items'].count).to eq(ITEM_NUM)
        expect(result['continuation']).to be_nil
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
        expect(result['items'].count).to eq(0)
        expect(result['continuation']).to be_nil
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
        expect(result['items'].count).to eq(ITEM_NUM)
        expect(result['continuation']).to be_nil
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
        expect(result['items'].count).to eq(0)
        expect(result['continuation']).to be_nil
      end
    end
  end
end
