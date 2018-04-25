# frozen_string_literal: true
require "rails_helper"

describe WallsController, type: :controller do
  let! (:wall) { Wall.create!(label: "news", description: "news tab")}
  let  (:user) { FactoryBot.create (:admin                                     )}

  before(:each) do
    login_user user
  end

  describe "GET index" do
    before { get :index }
    it { expect(assigns(:walls)).to eq([wall])  }
    it { expect(response).to render_template("index") }
  end

  describe "GET new" do
    before { get :new }
    it { expect(response).to render_template("new") }
  end

  describe "POST create" do
    label       = "new_wall"
    description = "desc"
    before { post :create, params: { wall: { label: label, description: description} }}
    it { expect(response).to redirect_to walls_url }
    it { expect(Wall.find_by(label: label).label).to eq(label) }
  end

  describe "GET edit" do
    before { get :edit, params: { id: wall.id }}
    it { expect(response).to render_template("edit") }
  end

  describe "POST update" do
    label = "changed"
    before { post :update, params: { id: wall.id, wall: { label: label } }}
    it { expect(response).to redirect_to walls_url }
    it { expect(Wall.find(wall.id).label).to eq(label) }
  end

  describe "DELETE destroy" do
    before { delete :destroy, params: { id: wall.id }}
    it { expect(response).to redirect_to walls_url }
    it { expect(Wall.find_by(id: wall.id)).to be_nil }
  end
end
