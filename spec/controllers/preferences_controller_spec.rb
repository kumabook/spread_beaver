# frozen_string_literal: true
require "rails_helper"

describe PreferencesController, type: :controller do
  let  (:user) { FactoryBot.create (:admin) }
  let! (:preference) { Preference.create!(key: "key", value: "value", user: user) }

  before(:each) do
    login_user user
  end

  describe "#index" do
    before { get :index, params: { user_id: user.id } }
    it { expect(assigns(:preferences)).to eq([preference])  }
    it { expect(response).to render_template("index") }
  end

  describe "#new" do
    before { get :new, params: { user_id: user.id } }
    it { expect(response).to render_template("new") }
  end

  describe "#create" do
    context "when succeeds in creating" do
      before {
        post :create, params: {
                      user_id:    user.id,
                      preference: { key: "new_key", value: "new_value"},
                    }
      }
      it { expect(response).to redirect_to user_preferences_url(user) }
      it { expect(Preference.find_by(user: user, key: "new_key").value).to eq("new_value") }
    end
    context "when fails to create" do
      before {
        allow_any_instance_of(Preference).to receive(:save).and_return(false)
        post :create, params: {
               user_id:    user.id,
               preference: { key: "new_key", value: "new_value"},
             }
      }
      it { expect(response).to render_template("new") }
    end
  end

  describe "#edit" do
    before { get :edit, params: { id: preference.id, user_id: user.id } }
    it { expect(response).to render_template("edit") }
  end

  describe "#update" do
     context "when succeeds in saving" do
      before {
        post :update, params: {
               id:         preference.id,
               user_id:    user.id,
               preference: { key: "key", value: "changed" }
             }
      }
      it { expect(response).to redirect_to user_preferences_url(user) }
      it { expect(Preference.find_by(user: user, key: "key").value).to eq("changed") }
     end
    context "when fails to save" do
      before {
        allow_any_instance_of(Preference).to receive(:update).and_return(false)
        post :update, params: {
               id:         preference.id,
               user_id:    user.id,
               preference: { key: "key", value: "changed" }
             }
      }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "#destroy" do
    context "when succeeds in saving" do
      before {
        delete :destroy, params: { id: preference.id, user_id: user.id }
      }
      it { expect(response).to redirect_to user_preferences_url(user) }
      it { expect(Preference.find_by(id: preference.id)).to be_nil }
    end
    context "when fails to save" do
      before {
        allow_any_instance_of(Preference).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: preference.id, user_id: user.id }
      }
      it { expect(response).to redirect_to user_preferences_url(user) }
    end
  end
end
