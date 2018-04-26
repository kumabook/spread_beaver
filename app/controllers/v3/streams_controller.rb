# frozen_string_literal: true

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
    @items = @items.select(&:has_visual?) if @need_visual
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
    h[:updated] = @stream.updated_at.to_time.to_i * 1000 if @stream.present?
    h[:title] = @title
    set_surrogate_key_header Entry.table_key, @items.map(&:record_key)
    render json: h, status: 200
  end

  private

  def set_items
    if @resource.present?
      @items = items_of_global_resource
    elsif @stream.present?
      @items = @stream.stream_entries(page: @page, per_page: @per_page, since: @newer_than)
    end
    if @items.nil?
      render_not_found
      return
    end
  end

  def items_of_global_resource
    case @resource
    when :latest
      Entry.latest_items(entries_per_feed: entries_per_feed,
                         since:            newer_than_from_param_or_default,
                         page:             @page,
                         per_page:         @per_page)
    when :all
      current_resource_owner.stream_entries(page:     @page,
                                            per_page: @per_page)
    when :hot, :popular
      items_of_mix_resource(@resource)
    when :liked, :saved, :read
      items_of_user_mark(@resource)
    end
  end

  def items_of_mix_resource(mix_type)
    case mix_type
    when :hot
      Entry.hot_items(query: mix_query_for_stream, page: @page, per_page: @per_page)
    when :popular
      Entry.popular_items(query: mix_query_for_stream, page: @page, per_page: @per_page)
    end
  end

  def items_of_user_mark(user_mark)
    Entry.page(@page).per(@per_page).try!(user_mark, @user)
  end
end
