# coding: utf-8
require 'rails_helper'

describe Tag do
  let (:user   ) { FactoryGirl.create (:admin)}
  let (:tag    ) { Tag.create!(label: "tag", description: "desc", user: user)}
  let (:entries) { FactoryGirl.create(:feed).entries }

  before do
    tag.entries = entries
    tag.save!
  end

  context "when entry is deleted" do
    count = 0
    before do
      count = entries.count
      entries[0].destroy!
    end
    it { expect(tag.entry_tags.count).to eq(count - 1) }
  end
end
