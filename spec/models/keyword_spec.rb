# coding: utf-8
require 'rails_helper'

describe Keyword do
  let! (:keyword) { Keyword.create!(label: "keyword", description: "desc")}
  let  (:entries) { FactoryGirl.create(:feed).entries }

  before do
    keyword.entries = entries
    keyword.save!
  end

  context "when entry is deleted" do
    count = 0
    before do
      count = entries.count
      entries[0].destroy!
    end
    it { expect(keyword.entry_keywords.count).to eq(count - 1) }
  end
end
