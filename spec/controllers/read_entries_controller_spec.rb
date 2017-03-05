require 'rails_helper'

describe ReadEntriesController, type: :controller do
  let (:user       ) { FactoryGirl.create (:admin                )}
  let (:entry      ) { FactoryGirl.create (:entry                )}
  let (:read_entry ) { ReadEntry.create!(entry: entry, user: user)}
  let (:user_entry ) { { user_id: user.id, entry_id: entry.id }   }

  before(:each) do
    login_user user
  end

  describe 'POST create' do
    before { post :create, params: { user_entry: user_entry }}
    it { expect(response).to redirect_to entries_url }
    it { expect(ReadEntry.find_by(user_entry).user.id).to  eq(user.id)  }
    it { expect(ReadEntry.find_by(user_entry).entry.id).to eq(entry.id) }
  end

  describe "DELETE destroy" do
    before { delete :destroy, params: { id: read_entry.id }}
    it { expect(response).to redirect_to entries_url }
    it { expect(ReadEntry.find_by(id: read_entry.id)).to be_nil }
  end
end
