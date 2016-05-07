require 'rails_helper'

RSpec.describe "Keywords api", :type => :request, autodoc: true do
  before(:all) do
    setup()
    login()
    (0...5).each do |i|
      Keyword.create!       label: "keyword-#{i}",
                      description: "description #{i}"
    end
  end

  it "get list of all keywords" do
    get "/v3/keywords",
        nil,
        Authorization: "Bearer #{@token['access_token']}"
    keywords = JSON.parse @response.body
    expect(keywords.count).to eq(5)
  end

  it "change the label of an existing keyword" do
    keyword = Keyword.all[0]
    hash = {
      label: "new-label",
      description: "new-description"
    }
    post "/v3/keywords/#{keyword.escape.id}", hash.to_json,
         Authorization: "Bearer #{@token['access_token']}",
          CONTENT_TYPE: 'application/json',
                ACCEPT: 'application/json'
    keyword = Keyword.find("keyword/new-label")
    expect(keyword.label).to eq("new-label")
    expect(keyword.description).to eq("new-description")
  end

  it "delete a keyword" do
    keyword = Keyword.all[0]
    delete "/v3/keywords/#{keyword.escape.id}", nil,
         Authorization: "Bearer #{@token['access_token']}",
          CONTENT_TYPE: 'application/json',
                ACCEPT: 'applfdfication/json'
    keywords = Keyword.all
    expect(keywords.count).to eq(4)
  end
end