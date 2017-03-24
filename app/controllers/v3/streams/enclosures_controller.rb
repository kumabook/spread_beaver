# coding: utf-8
class V3::Streams::EnclosuresController < V3::ApiController
  include Pagination
  before_action :doorkeeper_authorize!
  before_action :set_stream_id      , only: [:index]
  before_action :set_global_resource, only: [:index]
  before_action :set_enclosure_class, only: [:index]
  before_action :set_page           , only: [:index]

  DURATION             = Setting.duration_for_common_stream.days
  DURATION_FOR_RANKING = Setting.duration_for_ranking.days

  def index
    if @resource.nil? || @enclosure_class.nil?
      render json: {message: "Not found" }, status: :not_found
      return
    end

    case @resource
    when :latest
      since   = @newer_than.present? ? @newer_than : DURATION.ago
      @items = @enclosure_class.latest(since).page(@page).per(@per_page)
    when :hot
      from   = @newer_than.present? ? @newer_than : DURATION_FOR_RANKING.ago
      to     = @older_than.present? ? @older_than : from + DURATION_FOR_RANKING
      @items = @enclosure_class.hot_items_within_period(from:     from,
                                                        to:       to,
                                                        page:     @page,
                                                        per_page: @per_page)
    when :popular
      from    = @newer_than.present? ? @newer_than : DURATION_FOR_RANKING.ago
      to      = @older_than.present? ? @older_than : from + DURATION_FOR_RANKING
      @items  = @enclosure_class.popular_items_within_period(from:     from,
                                                             to:       to,
                                                             page:     @page,
                                                             per_page: @per_page)
    when :liked
      @items = @enclosure_class.page(@page)
                               .per(@per_page)
                               .liked(@user)
    when :saved
      @items = @enclosure_class.page(@page)
                               .per(@per_page)
                               .saved(@user)
    when :played
      @items = @enclosure_class.page(@page)
                               .per(@per_page)
                               .played(@user)
    else
      render json: {}, status: :not_found
      return
    end

    continuation = nil
    if @items.respond_to?(:total_count)
      if @items.total_count >= @per_page * @page + 1
        continuation = self.class::continuation(@page + 1, @per_page)
      end
    end
    if current_resource_owner.present?
      @enclosure_class.set_marks(current_resource_owner, @items)
    end
    @enclosure_class.set_contents(@items)
    if api_version == 0
      @items = @items.select {|i| i.legacy? }
    end
    h = {
      direction: "ltr",
      continuation: continuation,
      alternate: [],
      items: @items.map { |t| t.as_content_json }
    }
    render json: h, status: 200
  end

  def set_stream_id
    @stream_id = CGI.unescape params[:id] if params[:id].present?
  end

  def set_global_resource
    case @stream_id
    when /(tag|playlist)\/global\.latest/
      @resource = :latest
    when /(tag|playlist)\/global\.hot/
      @resource = :hot
    when /(tag|playlist)\/global\.popular/
      @resource = :popular
    when /user\/(.*)\/(tag|playlist)\/global\.all/
      @resource = :all
      @user     = User.find($1)
    when /user\/(.*)\/(tag|playlist)\/global\.liked/
      @resource = :liked
      @user     = User.find($1)
    when /user\/(.*)\/(tag|playlist)\/global\.saved/
      @resource = :saved
      @user     = User.find($1)
    when /user\/(.*)\/(tag|playlist)\/global\.played/
      @resource = :played
      @user     = User.find($1)
    end
  end

  def set_enclosure_class
    case params[:enclosures]
    when 'tracks'
      @enclosure_class = Track
    when 'playlists'
      @enclosure_class = Playlist
    when 'albums'
      @enclosure_class = Album
    end
  end
end
