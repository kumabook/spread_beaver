require 'rails_helper'

RSpec.describe "Albums  api", :type => :request, autodoc: true do
  before(:all) do
    setup()
    login()
    @feeds = (0...ITEM_NUM).to_a.map { FactoryGirl.create(:feed) }
    @like = EnclosureLike.create!(enclosure: @feeds[0].entries[0].albums[0],
                                  user: @user)
  end

  it "shows a album by id" do
    id = @feeds[0].entries[0].albums[0].id
    get "/v3/albums/#{id}", headers: headers_for_login_user_api
    album = JSON.parse @response.body
    expect(album).not_to be_nil()
    expect(album['id']).to eq(id)
    expect(album['entries']).not_to be_nil()
    expect(album['likers']).not_to be_nil()
    expect(album['likesCount']).not_to be_nil()
    expect(album['entriesCount']).not_to be_nil()
  end

  it "shows album list by id list" do
    ids = @feeds[0].entries[0].albums.map { |t| t.id }
    post "/v3/albums/.mget",
         params: ids.to_json,
         headers: headers_for_login_user_api
    albums = JSON.parse @response.body
    expect(albums).not_to be_nil()
    expect(albums.count).to eq(ids.count)
    albums.each_with_index {|t, i|
      expect(ids).to include(t['id'])
    }
  end
end