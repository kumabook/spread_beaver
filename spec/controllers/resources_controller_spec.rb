# frozen_string_literal: true
require "rails_helper"

describe ResourcesController, type: :controller do
  let! (:wall) { Wall.create!(label: "news", description: "news tab") }
  let! (:item) {
    Resource.create!(resource_id:   "journal/highlight",
                                  resource_type: "stream",
                                  wall_id:       wall.id,
                                  engagement:    0)
  }
  let (:user) { FactoryBot.create :admin }

  before(:each) do
    login_user user
  end

  describe "GET new" do
    before { get :new, params: { wall_id: wall.id } }
    it { expect(response).to render_template("new") }
  end

  describe "POST create" do
    resource_id   = "journal/fujirock"
    before {
      post :create, params: {
                    resource: {
                      resource_id: resource_id,
                      resource_type: "stream",
                      wall_id: wall.id,
                      engagement: 100
                    }
                  }
    }
    it { expect(response).to redirect_to edit_wall_url(wall) }
    it {
      expect(Resource.find_by(resource_id: resource_id,
                                 wall_id: wall.id)).not_to be_nil
    }
  end

  describe "GET edit" do
    before { get :edit, params: { id: item.id, wall_id: wall.id } }
    it { expect(response).to render_template("edit") }
  end

  describe "POST update" do
    before { post :update, params: { id: item.id, wall_id: wall.id, resource: { engagement: 100 }} }
    it { expect(response).to redirect_to edit_wall_url(wall) }
    it { expect(Resource.find(item.id).engagement).to eq(100) }
  end

  describe "DELETE destroy" do
    before { delete :destroy, params: { id: item.id } }
    it { expect(response).to redirect_to edit_wall_url(wall) }
    it { expect(Resource.find_by(id: item.id)).to be_nil }
  end
end
