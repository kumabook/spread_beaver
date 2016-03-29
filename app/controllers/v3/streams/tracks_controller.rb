class V3::Streams::TracksController < V3::ApiController
  include Pagination
  before_action :doorkeeper_authorize!
  before_action :set_global_resource, only: [:index]
  before_action :set_page           , only: [:index]

  DURATION = 3.days

  def index
    if @resource.nil?
      render json: {message: "Not found" }, status: 404
    end

    case @resource
    when :latest
      since   = @newer_than.present? ? @newer_than : DURATION.ago
      @tracks = Track.latest(since)
    when :popular
      from    = @newer_than.present? ? @newer_than : DURATION.ago
      to      = @older_than.present? ? @older_than : from + DURATION
      @tracks = Track.popular_tracks_within_period(from: from, to: to)
    when :all
      @subscriptions = current_resource_owner.subscriptions
      @entries = Entry.page(@page)
                      .per(@per_page)
                      .subscriptions(@subscriptions)
    when :liked
      @tracks = Entry.page(@page)
                     .per(@per_page)
                     .liked(current_resource_owner.id)
    else
      render json: {}, status: :not_found
      return
    end

    continuation = nil
    if @tracks.respond_to?(:total_count)
      if @tracks.total_count >= @per_page * @page + 1
        continuation = self.class::continuation(@page + 1, @per_page)
      end
    end
    h = {
      direction: "ltr",
      continuation: continuation,
      alternate: [],
      items: @tracks.map { |t| t.as_detail_json }
    }
    render json: h, status: 200
  end

  def set_global_resource
    str = CGI.unescape params[:id] if params[:id].present?
    if str.match /playlist\/global\.latest/
      @resource = :latest
    elsif str.match /playlist\/global\.popular/
      @resource = :popular
    elsif str.match /user\/.*\/playlist\/global\.all/
      @resource = :all
    elsif str.match /user\/.*\/playlist\/global\.liked/
      @resource = :liked
    end
  end
end
