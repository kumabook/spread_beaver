# frozen_string_literal: true
require "rails_helper"

describe TopicsController, type: :controller do
  let! (:topic) {     Topic.create!(label: "topic", description: "desc")}
  let  (:user ) { FactoryBot.create (:admin                           )}

  before(:each) do
    login_user user
  end

  describe "GET index" do
    before { get :index }
    it { expect(assigns(:topics)).to eq([topic])  }
    it { expect(response).to render_template("index") }
  end

  describe "GET new" do
    before { get :new }
    it { expect(response).to render_template("new") }
  end

  describe "POST create" do
    label       = "new_topic"
    description = "desc"
    context "when succeeds in creating" do
      before { post :create, params: { topic: { label: label, description: description} }}
      it { expect(response).to redirect_to topics_url }
      it { expect(Topic.find_by(label: label).label).to eq(label) }
    end
    context "when fails to create" do
      before {
        allow_any_instance_of(Topic).to receive(:save).and_return(false)
        post :create, params: { topic: { label: label, description: description} }
      }
      it { expect(response).to redirect_to topics_url }
      it { expect(flash[:notice]).not_to be_nil }
    end
  end

  describe "GET edit" do
    before { get :edit, params: { id: topic.id }}
    it { expect(response).to render_template("edit") }
  end

  describe "POST update" do
    label = "changed"
    context "when succeeds in saving" do
      before { post :update, params: { id: topic.id, topic: { label: label } }}
      it { expect(response).to redirect_to topics_url }
      it { expect(Topic.find("topic/changed").label).to eq(label) }
    end
    context "when fails to save" do
      before {
        allow_any_instance_of(Topic).to receive(:update).and_return(false)
        post :update, params: { id: topic.id, topic: { label: label } }
      }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "DELETE destroy" do
    context "when succeeds in saving" do
      before { delete :destroy, params: { id: topic.id }}
      it { expect(response).to redirect_to topics_url }
      it { expect(Topic.find_by(id: topic.id)).to be_nil }
    end
    context "when fails to save" do
      before {
        allow_any_instance_of(Topic).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: topic.id }
      }
      it { expect(response).to redirect_to topics_url }
    end
  end
end
