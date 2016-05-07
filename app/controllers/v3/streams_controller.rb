class V3::StreamsController < V3::ApiController
  include Pagination
  before_action :doorkeeper_authorize!
  before_action :set_stream_id      , only: [:index]
  before_action :set_global_resource, only: [:index]
  before_action :set_feed           , only: [:index]
  before_action :set_topic          , only: [:index]
  before_action :set_category       , only: [:index]
  before_action :set_need_visual    , only: [:index]
  before_action :set_page           , only: [:index]

  LATEST_ENTRIES_PER_FEED = 3
  DURATION                = 3.days

  def index
    if @resource.present?
      case @resource
      when :latest
        since    = @newer_than.present? ? @newer_than : DURATION.ago
        @entries = Entry.latest_entries(entries_per_feed: LATEST_ENTRIES_PER_FEED, since: since)
      when :all
        @subscriptions = current_resource_owner.subscriptions
        @entries = Entry.page(@page)
                        .per(@per_page)
                        .subscriptions(@subscriptions)
      when :popular
        from     = @newer_than.present? ? @newer_than : DURATION.ago
        to       = @older_than.present? ? @older_than : from + DURATION
        @entries = Entry.popular_entries_within_period(from: from, to: to)
      when :saved
        @entries = Entry.page(@page)
                        .per(@per_page)
                        .saved(current_resource_owner.id)
      else
        render json: {}, status: :not_found
        return
      end
    elsif @feed.present?
      @entries = Entry.page(@page)
                      .per(@per_page)
                      .feed(@feed)
    elsif @topic.present?
      @entries = Entry.page(@page)
                      .per(@per_page)
                      .topic(@topic)
    elsif @category.present?
      @entries = Entry.page(@page)
                      .per(@per_page)
                      .category(@category)
    end

    continuation = nil
    if @entries.nil?
      render json: {message: "Not found" }, status: 404
      return
    end
    if @entries.respond_to?(:total_count)
      if @entries.total_count >= @per_page * @page + 1
        continuation = self.class.continuation(@page + 1, @per_page)
      end
    end
    # TODO: currently visual is json string,
    # so we cannot check if the entry has visual or not.
    # Visual table should be created and check with where clause
    if @need_visual
      @entries = @entries.select { |entry| entry.has_visual? }
    end
    h = {
      direction: "ltr",
      continuation: continuation,
      alternate: [],
      items: @entries.map { |en| en.as_content_json }
    }
    if @feed.present?
      h[:updated] = @feed.updated_at.to_time.to_i * 1000
      h[:title]   = @feed.title
    end
    render json: h, status: 200
  end

  private

  def set_stream_id
    @stream_id = CGI.unescape params[:id] if params[:id].present?
  end

  def set_feed
    if params[:id].present? && @stream_id.match(/feed\/.*/)
      @feed = Feed.find_by(id: @stream_id)
    end
  end

  def set_topic
    if params[:id].present? && @stream_id.match(/topic\/.*/)
      @topic = Topic.includes(:feeds).find_by(id: @stream_id)
    end
  end

  def set_category
    if params[:id].present? && @stream_id.match(/user\/.*\/category\/.*/)
      @category = Category.includes(:subscriptions).find_by(id: @stream_id)
    end
  end

  def set_global_resource
    if @stream_id.match /tag\/global\.latest/
      @resource = :latest
    elsif @stream_id.match /tag\/global\.popular/
      @resource = :popular
    elsif @stream_id.match /user\/.*\/category\/global\.all/
      @resource = :all
    elsif @stream_id.match /user\/.*\/tag\/global\.saved/
      @resource = :saved
    end
  end

  def set_need_visual
    if @resource.present?
      @need_visual = true
    elsif @topic.present?
      @need_visual = true
    else
      @need_visual = false
    end
  end
end
