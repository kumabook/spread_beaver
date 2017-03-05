require 'rails_helper'

describe SavedEntriesController, type: :controller do
  let (:user        ) { FactoryGirl.create (:admin                 )}
  let (:entry       ) { FactoryGirl.create (:entry                 )}
  let (:saved_entry ) { SavedEntry.create!(entry: entry, user: user)}
  let (:user_entry  ) { { user_id: user.id, entry_id: entry.id }    }

  before(:each) do
    login_user user
  end

  describe 'POST create' do
    before { post :create, params: { user_entry: user_entry }}
    it { expect(response).to redirect_to entries_url }
    it { expect(SavedEntry.find_by(user_entry).user.id).to  eq(user.id)  }
    it { expect(SavedEntry.find_by(user_entry).entry.id).to eq(entry.id) }
  end

  describe "DELETE destroy" do
    before { delete :destroy, params: { id: saved_entry.id }}
    it { expect(response).to redirect_to entries_url }
    it { expect(SavedEntry.find_by(id: saved_entry.id)).to be_nil }
  end
end
