class V3::FeedsController < V3::ApiController
#  before_action :doorkeeper_authorize!
  before_action :set_feed,  only: [:show]
  before_action :set_feeds, only: [:list]

  def search
    @feeds = Feed.page(0)
                 .per(search_params[:count])
                 .search(search_params[:query])
                 .locale(search_params[:locale])
                 .order('velocity DESC')
    result = {
      related: [],
         hint: "",
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


  def list
    if @feeds.present?
      render json: @feeds.to_json, status: 200
    else
      render json: {}, status: :not_found
    end
  end


  def set_feed
    @feed = Feed.includes(:topics).find(CGI.unescape params[:id])
  end

  def set_feeds
    @feeds = Feed.includes(:topics).find(params['_json'])
    @feeds = params['_json'].map { |id|
      @feeds.select { |f| f.id == id }.first
    }
  end

  def search_params
    params.permit(:query, :count, :locale)
  end
end
