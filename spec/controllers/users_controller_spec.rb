require 'rails_helper'

describe UsersController, type: :controller do
  let (:user ) { FactoryBot.create (:admin)}

  before(:each) do
    login_user user
  end

  describe 'GET index' do
    before { get :index }
    it { expect(assigns(:users)).to eq([user.becomes(Admin)]) }
    it { expect(response).to render_template("index") }
  end

  describe 'GET new' do
    before { get :new }
    it { expect(response).to render_template("new") }
  end

  describe 'POST create' do
    email    = "new_user@example.com"
    password = 'password123'
    context 'when succeeds in creating' do
      before { post :create, params: {
                      user: {
                        email:                 email,
                        password:              password,
                        password_confirmation: password,
                      }
                    }
      }
      it { expect(User.find_by(email: email)).not_to be_nil }
      it { expect(response).to redirect_to user_url(User.find_by(email: email)) }
    end
    context 'when fails to create' do
      before {
        allow_any_instance_of(User).to receive(:save).and_return(false)
        post :create, params: { user: { email: email } }
      }
      it { expect(response).to render_template("new") }
      it { expect(flash[:notice]).not_to be_nil }
    end
  end

  describe 'GET edit' do
    before { get :edit, params: { id: user.id }}
    it { expect(response).to render_template("edit") }
  end

  describe 'POST update' do
    email = "changed@example.com"
    context 'when succeeds in saving' do
      before { post :update, params: { id: user.id, user: { email: email } }}
      it { expect(response).to redirect_to user_url(user) }
      it { expect(User.find(user.id).email).to eq(email) }
    end
    context 'when fails to save' do
      before {
        allow_any_instance_of(User).to receive(:update).and_return(false)
        post :update, params: { id: user.id, user: { email: email } }
      }
      it { expect(response).to render_template("edit") }
    end
  end

  describe "DELETE destroy" do
    context 'when succeeds in saving' do
      before { delete :destroy, params: { id: user.id }}
      it { expect(response).to redirect_to users_url }
      it { expect(User.find_by(id: user.id)).to be_nil }
    end
    context 'when fails to save' do
      before {
        allow_any_instance_of(User).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: user.id }
      }
      it { expect(response).to redirect_to users_url }
    end
  end
end
