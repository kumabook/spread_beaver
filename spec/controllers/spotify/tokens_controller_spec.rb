# frozen_string_literal: true
require 'rails_helper'

describe Spotify::TokensController, type: :controller do
  let (:code) { '1D72C0AED2E2425881750ADD075770D7' }
  let (:encrypted) {
    code.encrypt(:symmetric, password: Spotify::TokensController::ENCRYPTION_SECRET)
  }
  before do
    response = double
    allow(response).to receive(:code).and_return(200)
    allow(response).to receive(:body).and_return({ refresh_token: "xxxx" }.to_json)
    allow_any_instance_of(Net::HTTP).to receive(:request) do
      response
    end
  end
  describe '#swap' do
    before { post :swap, params: { code: code} }
    it { expect(JSON.parse(response.body)['refresh_token']).not_to be_nil }
  end

  describe '#refresh' do
    before { post :refresh, params: { refresh_token: encrypted } }
    it { expect(JSON.parse(response.body)['refresh_token']).not_to be_nil }
  end
end
