# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Preferences api", type: :request, autodoc: true do
  before(:all) do
    setup()
    login()
  end

  it "shows preferences of a user" do
    get "/v3/preferences",
        headers: headers_for_login_user_api
    preferences = JSON.parse @response.body
    expect(preferences.count).to eq(2)
  end

  it "updates preferences of a user" do
    hash = {
      key1: "new_value",
      key2: "==DELETE==",
      key3: "new_value",
    }
    post "/v3/preferences",
         params: hash.to_json,
         headers: headers_for_login_user_api
    get "/v3/preferences",
        headers: headers_for_login_user_api
    preferences = JSON.parse @response.body
    expect(preferences.count).to eq(2)
    expect(preferences["key1"]).to eq("new_value")
    expect(preferences["key2"]).to be_nil()
    expect(preferences["key3"]).to eq("new_value")
  end
end
