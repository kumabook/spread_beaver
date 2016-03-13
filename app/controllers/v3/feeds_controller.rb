class Api::V1::FeedsController < Api::V1::ApiController
  before_action :doorkeeper_authorize!
  def index
    @feeds = Feed.all
    render json: @feeds.to_json, status: 200
  end
end
