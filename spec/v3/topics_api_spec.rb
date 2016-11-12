require 'rails_helper'

RSpec.describe "Topics api", :type => :request, autodoc: true do
  before(:all) do
    setup()
    login()
    (0...5).each do |i|
      Topic.create! label: "label-#{i}",
                    description: "description #{i}"
    end
  end

  it "get list of all topics" do
    get "/v3/topics",
        headers: { Authorization: "Bearer #{@token['access_token']}" }
    topics = JSON.parse @response.body
    expect(topics.count).to eq(5)
  end

  it "change the label of an existing topic" do
    topic = Topic.all[0]
    hash = {
      label: "new-label",
      description: "new-description"
    }
    post "/v3/topics/#{topic.escape.id}",
         params: hash.to_json,
         headers: {
           Authorization: "Bearer #{@token['access_token']}",
           CONTENT_TYPE:  "application/json",
           ACCEPT:        "application/json"
         }
    topic = Topic.find("topic/new-label")
    expect(topic.label).to eq("new-label")
    expect(topic.description).to eq("new-description")
  end

  it "delete a topic" do
    topic = Topic.all[0]
    delete "/v3/topics/#{topic.escape.id}",
           headers: {
             Authorization: "Bearer #{@token['access_token']}",
             CONTENT_TYPE:  "application/json",
             ACCEPT:        "applfdfication/json"
           }
    topics = Topic.all
    expect(topics.count).to eq(4)
  end
end
