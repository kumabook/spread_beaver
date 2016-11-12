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
        headers: headers_for_login_user_api
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
         headers: headers_for_login_user_api
    topic = Topic.find("topic/new-label")
    expect(topic.label).to eq("new-label")
    expect(topic.description).to eq("new-description")
  end

  it "delete a topic" do
    topic = Topic.all[0]
    delete "/v3/topics/#{topic.escape.id}",
           headers: headers_for_login_user_api
    topics = Topic.all
    expect(topics.count).to eq(4)
  end
end
