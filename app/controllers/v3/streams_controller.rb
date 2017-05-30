class V3::StreamsController < V3::ApiController
  include Pagination
  include V3::StreamsControllable
  if Rails.env.production?
    before_action :doorkeeper_authorize!
  end
  before_action :set_entries

  LATEST_ENTRIES_PER_FEED = Setting.latest_entries_per_feed
  DURATION                = Setting.duration_for_common_stream.days
  DURATION_FOR_RANKING    = Setting.duration_for_ranking.days

  def index
    continuation = nil
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
    Entry.set_contents_of_enclosures(@entries)
    if current_resource_owner.present?
      Entry.set_marks(current_resource_owner, @entries)
      Entry.set_marks_of_enclosures(current_resource_owner, @entries)
    end
    only_legacy = api_version == 0
    h = {
      direction: "ltr",
      continuation: continuation,
      alternate: [],
      items: @entries.map { |en| en.as_content_json(only_legacy: only_legacy) }
    }
    if @feed.present?
      h[:updated] = @feed.updated_at.to_time.to_i * 1000
      h[:title]   = @feed.title
    end
    render json: h, status: 200
  end

  private

  def set_entries
    if @resource.present?
      case @resource
      when :latest
        since    = @newer_than.present? ? @newer_than : DURATION.ago
        @entries = Entry.latest_items(entries_per_feed: LATEST_ENTRIES_PER_FEED,
                                      since:            since,
                                      page:             @page,
                                      per_page:         @per_page)
      when :all
        @entries = current_resource_owner.stream_entries(page:     @page,
                                                         per_page: @per_page)
      when :hot
        from     = @newer_than.present? ? @newer_than : DURATION_FOR_RANKING.ago
        to       = @older_than.present? ? @older_than : Time.now
        @entries = Entry.hot_items_within_period(period: from..to, page: @page, per_page: @per_page)
      when :popular
        from     = @newer_than.present? ? @newer_than : DURATION_FOR_RANKING.ago
        to       = @older_than.present? ? @older_than : Time.now
        @entries = Entry.popular_items_within_period(period: from..to, page: @page, per_page: @per_page)
      when :liked
        @entries = Entry.page(@page)
                        .per(@per_page)
                        .liked(@user)
      when :saved
        @entries = Entry.page(@page)
                        .per(@per_page)
                        .saved(@user)
      when :read
        @entries = Entry.page(@page)
                        .per(@per_page)
                        .read(@user)
      else
        render json: {}, status: :not_found
        return
      end
    elsif @feed.present?
      @entries = @feed.stream_entries(page: @page, per_page: @per_page)
    elsif @keyword.present?
      @entries = @keyword.stream_entries(page: @page, per_page: @per_page)
    elsif @tag.present?
      @entries = @tag.stream_entries(page: @page, per_page: @per_page)
    elsif @topic.present?
      # TODO: Replace this with  mixes api
      since    = @newer_than.present? ? @newer_than : @topic.mix_newer_than
      q        = Mix::Query.new(since, LATEST_ENTRIES_PER_FEED)
      @entries = @topic.mix_entries(page: @page, per_page: @per_page, query: q)
    elsif @category.present?
      @entries = @category.stream_entries(page: @page, per_page: @per_page)
    elsif @journal.present?
      @issue   = @journal.current_issue
      @entries = @issue.stream_entries(page: @page, per_page: @per_page) if @issue.present?
    end
    if @entries.nil?
      render json: {message: "Not found" }, status: 404
      return
    end
  end
end
