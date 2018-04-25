# coding: utf-8
# frozen_string_literal: true
require "rails_helper"

describe Issue do
  let! (:journal) {     Journal.create!(label: "journal", description: "desc")}
  let! (:issue  ) {       Issue.create!(label: "issue"  , description: "desc", journal_id: journal.id)}
  let!  (:entries ) { FactoryBot.create(:feed).entries }

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

  describe "Issue#delete_cache" do
    context "when the issue is updated" do
      it {
        expect(issue).to receive(:delete_cache_entries)
        issue.update!(label: "new issue")
      }
    end

    context "when the entries of issue are updated" do
      it {
        expect(Issue).to receive(:delete_cache_of_stream)
        issue.entry_issues[0].update! engagement: 100
      }
      it {
        expect(Issue).to receive(:delete_cache_of_stream)
        issue.entries[0].destroy!
      }
    end
  end

end
