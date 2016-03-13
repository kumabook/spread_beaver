class V3::FeedsController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_feed, only: [:show]

  def search
    @feeds = Feed.page(0).per(search_params[:count]).all
    result = {
      related: [],
         hint: "music",
      results: @feeds
    }

    render json: result.to_json, status: 200
  end

  def show
    if @feed.present?
      render json: @feed.to_json, status: 200
    else
      render json: {}, status: :not_found
    end
  end

  def set_feed
    @feed = Feed.find(CGI.unescape params[:id])
  end

  def search_params
    params.permit(:query, :count, :locale)
  end
end
