# frozen_string_literal: true
require "rails_helper"

describe UserSessionsController, type: :controller do
  let! (:user) { FactoryBot.create :admin }

  describe "#create" do
    context "with correct email and password" do
      before { get :create, params: { email: user.email, password: "test_password" } }
      it { expect(response).to redirect_to users_url }
      it { expect(flash[:notice]).not_to be_nil }
    end

    context "with incorrect email and password" do
      before { get :create, params: { email: user.email, password: "incorrect" } }
      it { expect(response).to render_template("new") }
      it { expect(flash[:alert]).not_to be_nil }
    end
  end

  describe "#destroy" do
    before {
      login_user user
      post :destroy
    }
    it { expect(response).to redirect_to users_url }
    it { expect(flash[:notice]).not_to be_nil }
  end
end
