# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users api", type: :request, autodoc: true do
  before(:all) do
    setup()
  end

  describe "PUT /v3/profile" do
    it "create a user" do
      email    = "new_user@typica.com"
      password = "new_user_password"
      put "/v3/profile",
          params: {
            email: email,
            password: password,
            password_confirmation: password
          }
      me = JSON.parse @response.body
      expect(me["id"]).not_to be_nil
      expect(me["email"]).to eq(email)
    end
  end

  describe "GET /v3/profile" do
    before(:all) do
      login()
    end
    it "displays me" do
      get "/v3/profile",
          headers: headers_for_login_user_api
      me = JSON.parse @response.body
      expect(me["id"]).to    eq(@user.id)
      expect(me["email"]).to eq(@user.email)
    end
  end

  describe "POST /v3/profile" do
    before(:all) do
      login()
    end
    it "update me" do
      post "/v3/profile",
           params: {
             fullName: "full name",
           }.to_json,
           headers: headers_for_login_user_api
      me = JSON.parse @response.body
      expect(me["id"]).to    eq(@user.id)
      expect(me["email"]).to eq(@user.email)
      expect(me["fullName"]).to eq("full name")
    end
  end

  describe "GET /v3/profile/edit" do
    before(:all) do
      login()
    end
    it "get info for updating" do
      get "/v3/profile/edit",
          headers: headers_for_login_user_api
      me = JSON.parse @response.body
      expect(me["id"]).to    eq(@user.id)
      expect(me["email"]).to eq(@user.email)
      expect(me["picture_put_url"]).not_to be_nil
    end
  end

  describe "GET /v3/profile/:id" do
    before(:all) do
      login()
    end
    it "get a user info" do
      user = FactoryBot.create :member
      get "/v3/profile/#{user.id}",
          headers: headers_for_login_user_api
      u = JSON.parse @response.body
      expect(u["id"]).to    eq(user.id)
      expect(u["email"]).to eq(user.email)
    end
  end

  describe "PUT /v3/profile/:id" do
    before(:all) do
      @other = FactoryBot.create(:member)
    end
    context "admin" do
      before(:all) do
        create_admin()
        login_as_admin()
      end
      it "update a user info" do
        put "/v3/profile/#{@other.id}",
            params: {
              fullName: "full name",
            }.to_json,
            headers: headers_for_login_user_api
        expect(@response.status).to eq(200)
        u = JSON.parse @response.body
        expect(u["id"]).to    eq(@other.id)
        expect(u["email"]).to eq(@other.email)
        expect(u["fullName"]).to eq("full name")
      end
    end
    context "member" do
      before(:all) do
        login()
      end
      it "update a user info" do
        put "/v3/profile/#{@other.id}",
            params: {
              fullName: "full name",
            }.to_json,
            headers: headers_for_login_user_api
        expect(@response.status).to eq(404)
      end
    end
  end
end
