module ApiMacros
  def setup()
    @oauth = OAuth2::Client.new('client_id', 'client_secret') do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
    @app = Doorkeeper::Application.create!(name: 'ios',
                                           redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
    @email    = 'test@test.com'
    @password = 'test_password'
    @user = FactoryGirl.create(:member)
  end

  def login()
    post "/v3/oauth/token.json",
         grant_type:  'password',
         client_id: @app.uid,
         client_secret: @app.secret,
         email: @email,
         password: @password
    @token = JSON.parse @response.body
  end
end
