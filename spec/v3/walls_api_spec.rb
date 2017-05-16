require 'rails_helper'

RSpec.describe "Wall api", :type => :request, autodoc: true do
  before(:all) do
    setup()
    login()
    wall = Wall.create!(label: "ios/news",
                        description: "ios news tab")
    (0...5).each do |i|
      Resource.create!(wall_id:       wall.id,
                       engagement:    i,
                       resource_id:   "journal/#{i}",
                       resource_type: "stream")
    end
  end

  it "get resources of a specified collection" do
    get "/v3/walls/#{CGI.escape("ios/news")}",
        headers: headers_for_login_user_api
    resources = JSON.parse @response.body
    expect(resources['resources'].count).to eq(5)
  end
end
