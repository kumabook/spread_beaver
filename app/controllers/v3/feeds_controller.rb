class V3::FeedsController < V3::ApiController
#  before_action :doorkeeper_authorize!
  before_action :set_feed,  only: [:show]
  before_action :set_feeds, only: [:list]
  before_action :set_cache_control_headers, only: [:search, :show, :list]

  def search
    @feeds = Feed.search_by(query: search_params[:query],
                            locale: search_params[:locale],
                            page: 0,
                            per_page: search_params[:count])
    result = {
      related: [],
         hint: "",
      results: @feeds
    }
    set_surrogate_key_header Feed.table_key, @feeds.map(&:record_key)
    render json: result, status: 200
  end

  def show
    if @feed.present?
      set_surrogate_key_header @feed.record_key
      render json: @feed.to_json, status: 200
    else
      render_not_found
    end
  end


  def list
    if @feeds.present?
      set_surrogate_key_header Feed.table_key, @feeds.map(&:record_key)
      render json: @feeds.to_json, status: 200
    else
      render_not_found
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
