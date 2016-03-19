require 'rails_helper'

RSpec.describe "Entries api", :type => :request, autodoc: true do
  before(:all) do
    setup()
    login()
    @entries = FactoryGirl.create(:feed).entries
  end

  it "shows a entry by id" do
    id = @entries[0].id
    get "/v3/entries/#{id}", nil, Authorization: "Bearer #{@token['access_token']}"
    entry = JSON.parse @response.body
    expect(entry).not_to be_nil()
    expect(entry['id']).to eq(@entries[0].id)
  end

  it "shows entries list by id list" do
    ids = @entries.map { |e| e.id }
    post "/v3/entries/.mget", ids.to_json,
         Authorization: "Bearer #{@token['access_token']}",
          CONTENT_TYPE: 'application/json',
                Accept: 'application/json'
    entries = JSON.parse @response.body
    expect(entries).not_to be_nil()
    entries.each_with_index { |e, i|
      expect(e['id']).to eq(ids[i])
    }
  end
end
