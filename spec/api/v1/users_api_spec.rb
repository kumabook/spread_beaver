require 'rails_helper'

RSpec.describe "Users api", type: :request, autodoc: true do
  it "create a user" do
    email    = 'new_user@test.com'
    password = 'new_user_password'
    post "/api/v1/me", {
                           email: email,
                        password: password,
           password_confirmation: password
         }
    me = JSON.parse @response.body
    expect(me['id']).not_to    be_nil
    expect(me['email']).to eq(email)
  end
end
