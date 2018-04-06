# coding: utf-8
class V3::Streams::EnclosuresController < V3::ApiController
  include Pagination
  include StreamsControllable

  before_action :set_enclosure_class
  before_action :set_stream
  before_action :set_items
  before_action :set_cache_control_headers, only: [:show]

  def show
    if @items.nil? || @enclosure_class.nil?
      render json: {message: "Not found" }, status: :not_found
      return
    end

    continuation = self.class.calculate_continuation(@items, @page, @per_page)
    if current_resource_owner.present?
      @enclosure_class.set_marks(current_resource_owner, @items)
    end
    @enclosure_class.set_contents(@items)
    @enclosure_class.set_partial_entries(@items)
    if api_version == 0
      @items = @items.select {|i| i.legacy? }
    end
    h = {
      direction: "ltr",
      continuation: continuation,
      alternate: [],
      items: @items.map { |t| t.as_content_json }
    }
    if @stream.present?
      h[:updated] = @stream.updated_at.to_time.to_i * 1000
    end
    h[:title] = @title
    set_surrogate_key_header Entry.table_key, @items.map(&:record_key)
    render json: h, status: 200
  end

  def set_items
    if @resource.present?
      @items = items_of_global_resource
    elsif @stream.present?
      @items = @enclosure_class.page(@page)
                               .per(@per_page)
                               .provider(@provider)
                               .stream(@stream)
    end
  end

  private
  def items_of_global_resource
    case @resource
    when :latest
      @enclosure_class.latest(newer_than_from_param_or_default.ago)
        .page(@page)
        .per(@per_page)
        .provider(@provider)
    when :hot, :popular, :featured
      items_of_mix_resource(@resource)
    when :liked, :saved, :played
      items_of_user_mark(@resource)
    else
      nil
    end
  end

  def items_of_mix_resource(mix_type)
    case mix_type
    when :hot
      @enclosure_class.hot_items(query:    mix_query_for_stream,
                                 page:     @page,
                                 per_page: @per_page)
    when :popular
      @enclosure_class.popular_items(query:    mix_query_for_stream,
                                     page:     @page,
                                     per_page: @per_page)
    when :featured
      @enclosure_class.most_featured_items(query:    mix_query_for_stream,
                                           page:     @page,
                                           per_page: @per_page)
    end
  end

  def items_of_user_mark(user_mark)
    @enclosure_class
      .page(@page)
      .per(@per_page)
      .provider(@provider)
      .try!(user_mark, @user)
  end
end
