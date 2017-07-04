require 'rails_helper'

RSpec.describe "Users api", type: :request, autodoc: true do
  before(:all) do
    setup()
  end

  describe 'PUT /v3/profile' do
    it "create a user" do
      email    = 'new_user@typica.com'
      password = 'new_user_password'
      put "/v3/profile",
          params: {
            email: email,
            password: password,
            password_confirmation: password
          }
      me = JSON.parse @response.body
      expect(me['id']).not_to    be_nil
      expect(me['email']).to eq(email)
    end
  end

  describe 'GET /v3/profile' do
    before(:all) do
      login()
    end
    it "displays me" do
      get "/v3/profile",
          headers: headers_for_login_user_api
      me = JSON.parse @response.body
      expect(me['id']).to    eq(@user.id)
      expect(me['email']).to eq(@user.email)
    end
  end

  describe 'POST /v3/profile' do
    before(:all) do
      login()
    end
    it "update me" do
      post "/v3/profile",
           params: {
             fullName: 'full name',
           }.to_json,
           headers: headers_for_login_user_api
      me = JSON.parse @response.body
      expect(me['id']).to    eq(@user.id)
      expect(me['email']).to eq(@user.email)
      expect(me['fullName']).to eq('full name')
    end
  end
end
