require 'rails_helper'

describe CategoriesController, type: :controller do
  let  (:user) { FactoryGirl.create (:admin                               )}
  let! (:category ) { Category.create!(label: "category", description: "desc", user: user)}

  before(:each) do
    login_user user
  end

  describe 'GET index' do
    before { get :index }
    it { expect(assigns(:categories)).to eq([category])  }
    it { expect(response).to render_template("index") }
  end

  describe 'GET new' do
    before { get :new }
    it { expect(response).to render_template("new") }
  end

  describe 'POST create' do
    label = 'new_category'
    context 'when succeeds in creating' do
      before { post :create, params: { category: { label: label, description: 'desc'} }}
      it { expect(response).to redirect_to categories_url }
      it { expect(Category.find_by(label: label).label).to eq(label) }
    end
    context 'when fails to create' do
      before {
        allow_any_instance_of(Category).to receive(:save).and_return(false)
        post :create, params: { category: { label: 'category', description: 'desc'} }
      }
      it { expect(response).to redirect_to categories_url }
      it { expect(flash[:notice]).not_to be_nil }
    end
  end

  describe 'GET edit' do
    before { get :edit, params: { id: category.id }}
    it { expect(response).to render_template("edit") }
  end

  describe 'POST update' do
    label = "changed"
    context 'when succeeds in saving' do
      before {
        post :update, params: { id: category.id, category: { label: label } }
      }
      it { expect(response).to redirect_to categories_url }
      it { expect(Category.find("user/#{user.id}/category/changed").label).to eq(label) }
    end
    context 'when fails to save' do
      before {
        allow_any_instance_of(Category).to receive(:update).and_return(false)
        post :update, params: { id: category.id, category: { label: label } }
      }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "DELETE destroy" do
    context 'when succeeds in saving' do
      before {
        delete :destroy, params: { id: category.id }
      }
      it { expect(response).to redirect_to categories_url }
      it { expect(Category.find_by(id: category.id)).to be_nil }
    end
    context 'when fails to save' do
      before {
        allow_any_instance_of(Category).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: category.id }
      }
      it { expect(response).to redirect_to categories_url }
    end
  end
end
