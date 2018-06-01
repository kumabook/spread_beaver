# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthenticationsController, type: :controller do
  let (:user) { FactoryBot.create :admin }
  let (:other_user) { FactoryBot.create :member }

  let(:auth) {
    {
      user_id:  user.id,
      provider: "spotify",
      uid:      "typica.jp",
    }
  }

  let(:other_auth) {
    {
      user_id:  other_user.id,
      provider: "spotify",
      uid:      "typica.jp",
    }
  }

  describe "GET #spotify" do
    before(:each) do
      request.env["omniauth.auth"] = OmniAuth::AuthHash.new({
        provider: "spotify",
        uid:      "typica.jp",
        info: {
          display_name:  "typica",
          external_urls: { spotify: "https://open.spotify.com/user/typica.jp" },
          credentials:   { access_token: "access_token" },
          images:        [{ url: "http://example.com/imageurl.png" }],
        },
      })
    end

    context "action=connect" do
      before(:each) do
        login_user user
        request.env["omniauth.params"] = { "action" => "connect" }
      end
      context "not connected" do
        it "returns a success response" do
          get :spotify, params: { action: "connect" }
          expect(response).to redirect_to(edit_user_path(user))
        end
      end
      context "already connected with another user" do
        before(:each) { Authentication.create! other_auth }
        it "returns a success response" do
          get :spotify, params: { action: "connect" }
          expect(response).to redirect_to(edit_user_path(user))
        end
      end
    end

    context "action=login" do
      before(:each) do
        request.env["omniauth.params"] = { "action" => "login" }
      end
      context "not connected" do
        it do
          get :spotify, params: { action: "login" }
          expect(response).to redirect_to(root_path)
        end
      end
      context "already connected" do
        before(:each) { Authentication.create! auth }
        it do
          get :spotify, params: { action: "login" }
          expect(response).to redirect_to(:users)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      login_user user
    end

    it "destroys the requested authentication" do
      authentication = Authentication.create! auth
      expect {
        delete :destroy, params: {id: authentication.to_param}
      }.to change(Authentication, :count).by(-1)
    end

    it "redirects to the authentications list" do
      authentication = Authentication.create! auth
      delete :destroy, params: {id: authentication.to_param}
      expect(response).to redirect_to(edit_user_path(user))
    end
  end
end
