class V3::StreamsController < V3::ApiController
  include Pagination
  before_action :doorkeeper_authorize!
  before_action :set_stream_id      , only: [:index]
  before_action :set_global_resource, only: [:index]
  before_action :set_feed           , only: [:index]
  before_action :set_keyword        , only: [:index]
  before_action :set_tag            , only: [:index]
  before_action :set_journal        , only: [:index]
  before_action :set_topic          , only: [:index]
  before_action :set_category       , only: [:index]
  before_action :set_need_visual    , only: [:index]
  before_action :set_page           , only: [:index]

  LATEST_ENTRIES_PER_FEED = Setting.latest_entries_per_feed
  DURATION                = Setting.duration_for_common_stream.days
  DURATION_FOR_RANKING    = Setting.duration_for_ranking.days

  def index
    if @resource.present?
      case @resource
      when :latest
        since    = @newer_than.present? ? @newer_than : DURATION.ago
        @entries = Entry.latest_entries(entries_per_feed: LATEST_ENTRIES_PER_FEED,
                                                   since: since,
                                                    page: @page,
                                                per_page: @per_page)
      when :all
        @subscriptions = current_resource_owner.subscriptions
        @entries = Entry.page(@page)
                        .per(@per_page)
                        .subscriptions(@subscriptions)
      when :hot
        from     = @newer_than.present? ? @newer_than : DURATION_FOR_RANKING.ago
        to       = @older_than.present? ? @older_than : from + DURATION_FOR_RANKING
        @entries = Entry.hot_entries_within_period(from: from, to: to,
                                                   page: @page, per_page: @per_page)
      when :popular
        from     = @newer_than.present? ? @newer_than : DURATION_FOR_RANKING.ago
        to       = @older_than.present? ? @older_than : from + DURATION_FOR_RANKING
        @entries = Entry.popular_entries_within_period(from: from, to: to,
                                                       page: @page, per_page: @per_page)
      when :saved
        @entries = Entry.page(@page)
                        .per(@per_page)
                        .saved(current_resource_owner)
      else
        render json: {}, status: :not_found
        return
      end
    elsif @feed.present?
      @entries = Entry.page(@page)
                      .per(@per_page)
                      .feed(@feed)
    elsif @keyword.present?
      @entries = Entry.page(@page)
                      .per(@per_page)
                      .keyword(@keyword)
    elsif @tag.present?
      @entries = Entry.page(@page)
                      .per(@per_page)
                      .tag(@tag)
    elsif @topic.present?
      # TODO: Replace this with  mixes api
      since    = @newer_than.present? ? @newer_than : DURATION.ago
      @entries = Entry.latest_entries_of_topic(@topic,
                                               since: since,
                                                page: @page,
                                            per_page: @per_page)
    elsif @category.present?
      @entries = Entry.page(@page)
                      .per(@per_page)
                      .category(@category)
    elsif @journal.present?
      @entries = Entry.page(@page)
                      .per(@per_page)
                      .issue(@journal.current_issue)
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

  def set_keyword
    if params[:id].present? && @stream_id.match(/keyword\/.*/)
      @keyword = Keyword.find_by(id: @stream_id)
    end
  end

  def set_tag
    if params[:id].present? && @stream_id.match(/user\/.*\/tag\/.*/)
      @tag = Tag.find_by(id: @stream_id)
    end
  end

  def set_journal
    if params[:id].present? && @stream_id.match(/journal\/.*/)
      @journal = Journal.find_by(stream_id: @stream_id)
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
    elsif @stream_id.match /tag\/global\.hot/
      @resource = :hot
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
