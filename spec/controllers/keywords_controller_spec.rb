# frozen_string_literal: true
require "rails_helper"

describe KeywordsController, type: :controller do
  let! (:keyword) {     Keyword.create!(label: "keyword", description: "desc")}
  let  (:user   ) { FactoryBot.create (:admin                               )}

  before(:each) do
    login_user user
  end

  describe "GET index" do
    before { get :index }
    it { expect(assigns(:keywords)).to eq([keyword])  }
    it { expect(response).to render_template("index") }
  end

  describe "GET new" do
    before { get :new }
    it { expect(response).to render_template("new") }
  end

  describe "POST create" do
    label       = "new_keyword"
    description = "desc"
    context "when succeeds in creating" do
      before { post :create, params: { keyword: { label: label, description: description} }}
      it { expect(response).to redirect_to keywords_url }
      it { expect(Keyword.find_by(label: label).label).to eq(label) }
    end
    context "when fails to create" do
      before {
        allow_any_instance_of(Keyword).to receive(:save).and_return(false)
        post :create, params: { keyword: { label: label, description: description} }
      }
      it { expect(response).to redirect_to keywords_url }
      it { expect(flash[:notice]).not_to be_nil }
    end
  end

  describe "GET edit" do
    before { get :edit, params: { id: keyword.id }}
    it { expect(response).to render_template("edit") }
  end

  describe "POST update" do
    label = "changed"
    context "when succeeds in saving" do
      before { post :update, params: { id: keyword.id, keyword: { label: label } }}
      it { expect(response).to redirect_to keywords_url }
      it { expect(Keyword.find("keyword/changed").label).to eq(label) }
    end
    context "when fails to save" do
      before {
        allow_any_instance_of(Keyword).to receive(:update).and_return(false)
        post :update, params: { id: keyword.id, keyword: { label: label } }
      }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "DELETE destroy" do
    context "when succeeds in saving" do
      before { delete :destroy, params: { id: keyword.id }}
      it { expect(response).to redirect_to keywords_url }
      it { expect(Keyword.find_by(id: keyword.id)).to be_nil }
    end
    context "when fails to save" do
      before {
        allow_any_instance_of(Keyword).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: keyword.id }
      }
      it { expect(response).to redirect_to keywords_url }
    end
  end
end
