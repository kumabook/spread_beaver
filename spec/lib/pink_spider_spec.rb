# coding: utf-8
require 'rails_helper'
require 'pink_spider'

describe PinkSpider do
  let (:header     ) { { accept: :json } }
  let (:mget_header) { { content_type: :json, accept: :json } }
  before do
    @pink_spider = PinkSpider.new(nil)
    response = double
    allow(response).to receive(:code).and_return(200)
    allow(response).to receive(:body).and_return("{}")
    allow(RestClient).to receive(:get).and_return(response)
    allow(RestClient).to receive(:post).and_return(response)
  end
  describe "#initialize" do
    context "with no url" do
      it { expect(@pink_spider.base_url).to eq('http://localhost:8080') }
    end
    context "with url" do
      before { @pink_spider = PinkSpider.new('http://pink-spider.herokuapp.com') }
      it { expect(@pink_spider.base_url).to eq('http://pink-spider.herokuapp.com') }
    end
  end

  describe "#fetch_track" do
    it do
      expect(RestClient).to receive(:get).with(
                              'http://localhost:8080/v1/tracks/id',
                              header,
                            )
      @pink_spider.fetch_track('id')
    end
  end
  describe "#fetch_tracks" do
    it do
      expect(RestClient).to receive(:post).with(
                              'http://localhost:8080/v1/tracks/.mget',
                              ['id'].to_json, mget_header)
      @pink_spider.fetch_tracks(['id'])
    end
  end
  describe "#fetch_playlist" do
    it do
      expect(RestClient).to receive(:get).with(
                              'http://localhost:8080/v1/playlists/id',
                              header)
      @pink_spider.fetch_playlist('id')
    end
  end
  describe "#fetch_playlists" do
    it do
      expect(RestClient).to receive(:post).with(
                              'http://localhost:8080/v1/playlists/.mget',
                              ['id'].to_json, mget_header)
      @pink_spider.fetch_playlists(['id'])
    end
  end
  describe "#fetch_album" do
    it do
      expect(RestClient).to receive(:get).with(
                              'http://localhost:8080/v1/albums/id',
                              header)
      @pink_spider.fetch_album('id')
    end
  end
  describe "#fetch_albums" do
    it do
      expect(RestClient).to receive(:post).with(
                              'http://localhost:8080/v1/albums/.mget',
                              ['id'].to_json, mget_header)
      @pink_spider.fetch_albums(['id'])
    end
  end
end
