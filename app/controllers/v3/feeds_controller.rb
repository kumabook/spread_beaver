class V3::FeedsController < V3::ApiController
  before_action :doorkeeper_authorize!
  def index
    @feeds = Feed.all
    render json: @feeds.to_json, status: 200
  end
end
