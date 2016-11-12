require 'rails_helper'

RSpec.describe "Credentials api", :type => :request, autodoc: true do
  before(:all) do
    setup()
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
