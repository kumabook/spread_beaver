# coding: utf-8
require 'rails_helper'

describe Issue do
  let! (:journal) {     Journal.create!(label: "journal", description: "desc")}
  let! (:issue  ) {       Issue.create!(label: "issue"  , description: "desc", journal_id: journal.id)}
  let!  (:entries ) { FactoryGirl.create(:feed).entries }

  before do
    issue.entries = entries
    issue.save!
  end

  context "when entry is deleted" do
    count = 0
    before do
      count = entries.count
      entries[0].destroy!
    end
    it { expect(issue.entry_issues.count).to eq(count - 1) }
  end
end
