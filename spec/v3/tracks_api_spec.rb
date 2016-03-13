require 'rails_helper'

RSpec.describe "Tracks api", :type => :request, autodoc: true do
  before(:all) do
    setup()
    login()
    @feeds = (0...ITEM_NUM).to_a.map { FactoryGirl.create(:feed) }
  end

  it "shows a track by id" do
    id = @feeds[0].entries[0].tracks[0].id
    get "/v3/tracks/#{id}", nil, Authorization: "Bearer #{@token['access_token']}"
    track = JSON.parse @response.body
    expect(track).not_to be_nil()
    expect(track['id']).to eq(id)
  end
end
