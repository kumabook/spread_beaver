# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tags api", type: :request, autodoc: true do
  before(:all) do
    setup()
    login()
    @feed = FactoryBot.create(:feed)
    (0...5).each do |i|
      Tag.create! user: @user,
                  label: "tag-#{i}",
                  description: "description #{i}"
    end
  end

  it "get list of all tags" do
    get "/v3/tags",
        headers: headers_for_login_user_api
    tags = JSON.parse @response.body
    expect(tags.count).to eq(5)
  end

  it "change the label of an existing tag" do
    tag = Tag.all[0]
    hash = {
      label: "new-label",
      description: "new-description"
    }
    post "/v3/tags/#{tag.escape.id}",
         params: hash.to_json,
         headers: headers_for_login_user_api
    tag = Tag.find("user/#{@user.id}/tag/new-label")
    expect(tag.label).to eq("new-label")
    expect(tag.description).to eq("new-description")
  end

  it "delete tags" do
    tags = Tag.all
    tag_ids = tags.map { |t| t.escape.id }.join(",")
    delete "/v3/tags/#{tag_ids}",
           headers: headers_for_login_user_api
    expect(Tag.all.count).to eq(0)
  end

  it "tag entry" do
    tags = Tag.all
    tag_ids  = tags.map { |t| t.escape.id }.join(",")
    entry_id = @feed.entries[0].id
    put "/v3/tags/#{tag_ids}",
        params: { entryId: entry_id }.to_json,
        headers: headers_for_login_user_api
    expect(Entry.find(entry_id).tags.count).to eq(5)
  end

  it "tag multiple entries" do
    tags      = Tag.all
    entries   = @feed.entries[0..1]
    tag_ids   = tags.map { |t| t.escape.id }.join(",")
    entry_ids = entries.map(&:id).join(",")
    put "/v3/tags/#{tag_ids}/#{entry_ids}",
        headers: headers_for_login_user_api
    entries.each do |entry|
      expect(Entry.find(entry.id).tags.count).to eq(5)
    end
  end

  it "untag multiple entries" do
    tags      = Tag.all
    entries   = @feed.entries[0..1]

    entries.each do |entry|
      entry.update(tags: entry.tags + tags)
    end

    tag_ids   = tags.map { |t| t.escape.id }.join(",")
    entry_ids = entries.map(&:id).join(",")
    delete "/v3/tags/#{tag_ids}/#{entry_ids}",
           headers: headers_for_login_user_api
    entries.each do |entry|
      expect(Entry.find(entry.id).tags.count).to eq(0)
    end
  end
end
