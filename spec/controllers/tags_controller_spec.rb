require 'rails_helper'

describe TagsController, type: :controller do
  let  (:user) { FactoryGirl.create (:admin                               )}
  let! (:tag ) { Tag.create!(label: "tag", description: "desc", user: user)}

  before(:each) do
    login_user user
  end

  describe '#index' do
    before { get :index }
    it { expect(assigns(:tags)).to eq([tag])  }
    it { expect(response).to render_template("index") }
  end

  describe '#new' do
    before { get :new }
    it { expect(response).to render_template("new") }
  end

  describe '#create' do
    label = 'new_tag'
    context 'when succeeds in creating' do
      before { post :create, params: { tag: { label: label, description: 'desc'} }}
      it { expect(response).to redirect_to tags_url }
      it { expect(Tag.find_by(label: label).label).to eq(label) }
    end
    context 'when fails to create' do
      before {
        allow_any_instance_of(Tag).to receive(:save).and_return(false)
        post :create, params: { tag: { label: 'tag', description: 'desc'} }
      }
      it { expect(response).to redirect_to tags_url }
      it { expect(flash[:notice]).not_to be_nil }
    end
  end

  describe '#edit' do
    before { get :edit, params: { id: tag.id }}
    it { expect(response).to render_template("edit") }
  end

  describe '#update' do
    label = "changed"
    context 'when succeeds in saving' do
      before {
        post :update, params: { id: tag.id, tag: { label: label } }
      }
      it { expect(response).to redirect_to tags_url }
      it { expect(Tag.find("user/#{user.id}/tag/changed").label).to eq(label) }
    end
    context 'when fails to save' do
      before {
        allow_any_instance_of(Tag).to receive(:update).and_return(false)
        post :update, params: { id: tag.id, tag: { label: label } }
      }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "#destroy" do
    context 'when succeeds in saving' do
      before {
        delete :destroy, params: { id: tag.id }
      }
      it { expect(response).to redirect_to tags_url }
      it { expect(Tag.find_by(id: tag.id)).to be_nil }
    end
    context 'when fails to save' do
      before {
        allow_any_instance_of(Tag).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: tag.id }
      }
      it { expect(response).to redirect_to tags_url }
    end
  end
end
