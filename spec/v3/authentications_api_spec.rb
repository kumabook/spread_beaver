# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentications api", type: :request, autodoc: true do
  before(:all) do
    setup()
    login()
  end

  let(:auth) {
    {
      user_id:  @user.id,
      provider: "spotify",
      uid:      "typica.jp",
    }
  }

  describe "DELETE /v3/profile/:profile/:provider" do
    it "destroys the requested identity" do
      authentication = Authentication.create! auth
      expect {
        delete "/v3/profile/#{@user.id}/spotify",
               headers: headers_for_login_user_api
        @response.status
      }.to change(Authentication, :count).by(-1)
    end
  end
end
