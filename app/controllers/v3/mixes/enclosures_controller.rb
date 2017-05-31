# coding: utf-8
class V3::Mixes::EnclosuresController < V3::ApiController
  include Pagination
  include V3::StreamsControllable
  before_action :doorkeeper_authorize!
  before_action :set_enclosure_class, only: [:index]
  before_action :set_mix_type
  before_action :set_stream
  before_action :set_period
  before_action :set_items          , only: [:index]

  DURATION             = Setting.duration_for_common_stream.days
  DURATION_FOR_RANKING = Setting.duration_for_ranking.days

  def index
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
      items: @items.map { |t| t.as_content_json }
    }
    render json: h, status: 200
  end

  def set_items
    query = Mix::Query.new(@period, @type)
    if @stream.present?
      @items = @stream.mix_enclosures(@enclosure_class,
                                      page:     @page,
                                      per_page: @per_page,
                                      query:    query)
    end
  end
end