# coding: utf-8
class V3::Mixes::EnclosuresController < V3::ApiController
  include Pagination
  include StreamsControllable

  before_action :set_enclosure_class
  before_action :set_mix_type
  before_action :set_stream
  before_action :set_period
  before_action :set_items
  before_action :set_cache_control_headers, only: [:show]

  DURATION             = Setting.duration_for_common_stream.days
  DURATION_FOR_RANKING = Setting.duration_for_ranking.days

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
    set_surrogate_key_header @enclosure_class.table_key, @items.map(&:record_key)
    render json: h, status: 200
  end

  def set_items
    query = Mix::Query.new(@period, @type, locale: @locale, provider: @provider)
    if @stream.present?
      @items = @stream.mix_enclosures(@enclosure_class,
                                      page:     @page,
                                      per_page: @per_page,
                                      query:    query)
    end
  end
end
