# coding: utf-8
# frozen_string_literal: true
require "rails_helper"

describe Subscription do
  let! (:user)  { FactoryBot.create(:default) }
  let! (:feed1) { FactoryBot.create(:feed) }
  let! (:feed2) { FactoryBot.create(:feed) }
  let! (:subscription1) { Subscription.create! user: user,
                                               feed: feed1 }
  let! (:subscription2) { Subscription.create! user: user,
                                               feed: feed2 }

  describe "Subscription.of" do
    it {
      expect(Subscription.of(user).count).to eq(2)
      subscription2.destroy!
      user.reload
      expect(Subscription.of(user).count).to eq(1)
    }

    it {
      expect(Subscription.of(user).count).to eq(2)
      feed1.destroy!
      user.reload
      expect(Subscription.of(user).count).to eq(1)
    }
  end
end
