# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Entries api", type: :request, autodoc: true do
  before(:all) do
    setup()
    login()
    @entries = FactoryBot.create(:feed).entries
  end

  it "shows a entry by id" do
    id = @entries[0].id
    get "/v3/entries/#{id}",
        headers: headers_for_login_user_api
    e = JSON.parse @response.body
    expect(e).not_to be_nil()
    expect(e["id"]).to eq(@entries[0].id)
    expect(e["tracks"].length).to be > 0
    expect(e["tracks"][0]["entries"].length).to be > 0
    expect(e["tracks"][0]["entries"][0]["summary"]).to be_nil
  end

  it "shows entries list by id list" do
    ids = @entries.map(&:id)
    ids.push "unknown_id"
    post "/v3/entries/.mget",
         params: ids.to_json,
         headers: headers_for_login_user_api
    entries = JSON.parse @response.body
    expect(entries).not_to be_nil()
    expect(entries.count).to eq(@entries.count)
    entries.each_with_index { |e, i|
      expect(e["id"]).to eq(ids[i])
      expect(e["tracks"].length).to be > 0
      expect(e["tracks"][0]["entries"].length).to be > 0
      expect(e["tracks"][0]["entries"][0]["summary"]).to be_nil
    }
  end
end
