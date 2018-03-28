# coding: utf-8
class V3::Streams::EnclosuresController < V3::ApiController
  include Pagination
  include V3::StreamsControllable

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
    if api_version == 0
      @items = @items.select {|i| i.legacy? }
    end
    h = {
      direction: "ltr",
      continuation: continuation,
      alternate: [],
      items: @items.map { |t| t.as_detail_json }
    }
    if @stream.present?
      h[:updated] = @stream.updated_at.to_time.to_i * 1000
    end
    h[:title] = @title
    set_surrogate_key_header Entry.table_key, @items.map(&:record_key)
    render json: h, status: 200
  end

  def set_items
    duration             = Setting.duration_for_common_stream&.days || 5.days
    duration_for_ranking = Setting.duration_for_ranking&.days || 3.days

    if @resource.present?
      case @resource
      when :latest
        since   = @newer_than.present? ? @newer_than : duration.ago
        @items = @enclosure_class.latest(since)
                                 .page(@page)
                                 .per(@per_page)
                                 .provider(@provider)
      when :hot
        from   = @newer_than.present? ? @newer_than : duration_for_ranking.ago
        to     = @older_than.present? ? @older_than : Time.now
        @items = @enclosure_class.hot_items(period:   from..to,
                                            page:     @page,
                                            per_page: @per_page,
                                            provider: @provider)
      when :popular
        from    = @newer_than.present? ? @newer_than : duration_for_ranking.ago
        to      = @older_than.present? ? @older_than : Time.now
        @items  = @enclosure_class.popular_items(period:   from..to,
                                                 page:     @page,
                                                 per_page: @per_page,
                                                 provider: @provider)
      when :featured
        from    = @newer_than.present? ? @newer_than : duration_for_ranking.ago
        to      = @older_than.present? ? @older_than : Time.now
        @items  = @enclosure_class.most_featured_items(period:   from..to,
                                                       page:     @page,
                                                       per_page: @per_page,
                                                       provider: @provider)
      when :liked
        @items = @enclosure_class.page(@page)
                                 .per(@per_page)
                                 .provider(@provider)
                                 .liked(@user)
      when :saved
        @items = @enclosure_class.page(@page)
                                 .per(@per_page)
                                 .provider(@provider)
                                 .saved(@user)
      when :played
        @items = @enclosure_class.page(@page)
                                 .per(@per_page)
                                 .provider(@provider)
                                 .played(@user)
      end
    elsif @stream.present?
      @items = @enclosure_class.page(@page)
                               .per(@per_page)
                               .provider(@provider)
                               .stream(@stream)
    end
  end
end
