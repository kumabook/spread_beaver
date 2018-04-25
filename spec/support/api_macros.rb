# frozen_string_literal: true
module ApiMacros
  def setup()
    @oauth = OAuth2::Client.new("client_id", "client_secret") do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
    @app = Doorkeeper::Application.create!(name: "ios",
                                           redirect_uri: "urn:ietf:wg:oauth:2.0:oob")
    @email    = "test@test.com"
    @password = "test_password"
    @user = FactoryBot.create(:default)
  end

  def create_admin
    @admin = FactoryBot.create(:admin)
    @admin_email    = @admin.email
    @admin_password = "test_password"
  end

  def login()
    post "/v3/oauth/token.json", params: {
           grant_type:  "password",
           client_id: @app.uid,
           client_secret: @app.secret,
           email: @email,
           password: @password
         }
    @token = JSON.parse @response.body
  end

  def login_as_admin()
    post "/v3/oauth/token.json", params: {
           grant_type:  "password",
           client_id: @app.uid,
           client_secret: @app.secret,
           email: @admin_email,
           password: @admin_password
         }
    @token = JSON.parse @response.body
  end

  def headers_for_login_user_api
    {
      Authorization: "Bearer #{@token['access_token']}",
      CONTENT_TYPE:  "application/json",
      ACCEPT:        "application/json",
      "X-Api-Version": "1"
    }
  end

  def headers_for_legacy_login_user_api
    {
      Authorization: "Bearer #{@token['access_token']}",
      CONTENT_TYPE:  "application/json",
      ACCEPT:        "application/json",
    }
  end

  def headers_for_login_user
    {
      Authorization: "Bearer #{@token['access_token']}"
    }
  end
end
