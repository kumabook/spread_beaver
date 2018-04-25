# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Categories api", :type => :request, autodoc: true do
  before(:all) do
    setup()
    login()
    (0...5).each do |i|
      Category.create! user: @user,
                       label: "label-#{i}",
                       description: "description #{i}"
    end
  end

  it "get list of all categories of current user" do
    get "/v3/categories", headers: { Authorization: "Bearer #{@token['access_token']}" }
    categories = JSON.parse @response.body
    expect(categories.count).to eq(5)
  end

  it "change the label of an existing category" do
    category = Category.where(user: @user)[0]
    hash = {
      label: "new-label",
      description: "new-description"
    }
    post "/v3/categories/#{category.escape.id}",
         params: hash.to_json,
         headers: headers_for_login_user_api
    category = Category.find("user/#{@user.id}/category/new-label")
    expect(category.label).to eq("new-label")
    expect(category.description).to eq("new-description")
  end

  it "delete a category" do
    category = Category.where(user: @user)[0]
    hash = {
      label: "new-label",
    }
    delete "/v3/categories/#{category.escape.id}",
           params: hash.to_json,
           headers: headers_for_login_user_api
    categories = Category.where(user: @user)
    expect(categories.count).to eq(4)
  end
end
