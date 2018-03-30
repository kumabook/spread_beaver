class V3::StreamsController < V3::ApiController
  include Pagination
  include StreamsControllable
  before_action :set_stream
  before_action :set_items
  before_action :set_cache_control_headers, only: [:show]

  def show
    continuation = self.class.calculate_continuation(@items, @page, @per_page)
    # TODO: currently visual is json string,
    # so we cannot check if the entry has visual or not.
    # Visual table should be created and check with where clause
    if @need_visual
      @items = @items.select { |entry| entry.has_visual? }
    end
    Entry.set_contents_of_enclosures(@items)
    if current_resource_owner.present?
      Entry.set_marks(current_resource_owner, @items)
      Entry.set_marks_of_enclosures(current_resource_owner, @items)
    end
    only_legacy = api_version == 0
    h = {
      direction: "ltr",
      continuation: continuation,
      alternate: [],
      items: @items.map { |en| en.as_content_json(only_legacy: only_legacy) }
    }
    if @stream.present?
      h[:updated] = @stream.updated_at.to_time.to_i * 1000
    end
    h[:title] = @title
    set_surrogate_key_header Entry.table_key, @items.map(&:record_key)
    render json: h, status: 200
  end

  private

  def set_items
    duration = Setting.duration_for_common_stream&.days || 5.days

    if @resource.present?
      case @resource
      when :latest
        since    = @newer_than.present? ? @newer_than : duration.ago
        @items = Entry.latest_items(entries_per_feed: entries_per_feed,
                                    since:            since,
                                    page:             @page,
                                    per_page:         @per_page)
      when :all
        @items = current_resource_owner.stream_entries(page:     @page,
                                                       per_page: @per_page)
      when :hot
        @items = Entry.hot_items(query: mix_query_for_stream, page: @page, per_page: @per_page)
      when :popular
        @items = Entry.popular_items(query: mix_query_for_stream, page: @page, per_page: @per_page)
      when :liked
        @items = Entry.page(@page)
                      .per(@per_page)
                      .liked(@user)
      when :saved
        @items = Entry.page(@page)
                      .per(@per_page)
                      .saved(@user)
      when :read
        @items = Entry.page(@page)
                      .per(@per_page)
                      .read(@user)
      else
        render_not_found
        return
      end
    elsif @feed.present?
      @items = @feed.stream_entries(page: @page, per_page: @per_page)
    elsif @keyword.present?
      @items = @keyword.stream_entries(page: @page, per_page: @per_page)
    elsif @tag.present?
      @items = @tag.stream_entries(page: @page, per_page: @per_page)
    elsif @topic.present?
      @items = @topic.stream_entries(page: @page, per_page: @per_page, since: @newer_than)
    elsif @category.present?
      @items = @category.stream_entries(page: @page, per_page: @per_page)
    elsif @journal.present?
      @issue   = @journal.current_issue
      @items = @issue.stream_entries(page: @page, per_page: @per_page) if @issue.present?
    end
    if @items.nil?
      render_not_found
      return
    end
  end
end
