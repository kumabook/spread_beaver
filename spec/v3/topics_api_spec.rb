# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Topics api", :type => :request, autodoc: true do
  before(:all) do
    setup()
    login()
    Topic.create! label:       "label-0",
                  description: "description 0",
                  locale:      nil
    (1...3).each do |i|
      Topic.create! label:       "label-#{i}",
                    description: "description #{i}",
                    locale:      "ja"
    end
    (3...5).each do |i|
      Topic.create! label:       "label-#{i}",
                    description: "description #{i}",
                    locale:      "en"
    end
  end

  it "get list of all topics" do
=begin
TODO: reenable after client update
    get "/v3/topics", {
          params:  { locale: nil },
          headers: headers_for_login_user_api
        }
    topics = JSON.parse @response.body
    expect(topics.count).to eq(5)
=end
  end

  it "get list of specified locale topics" do
    get "/v3/topics", {
          params:  { locale: "ja" },
          headers: headers_for_login_user_api
        }
    ja_topics = JSON.parse @response.body
    expect(ja_topics.count).to eq(2)

    get "/v3/topics", {
          params:  { locale: "en" },
          headers: headers_for_login_user_api
        }
    en_topics = JSON.parse @response.body
    expect(en_topics.count).to eq(2)
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
