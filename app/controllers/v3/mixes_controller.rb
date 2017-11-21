class V3::MixesController < V3::ApiController
  include Pagination
  include V3::StreamsControllable
  before_action :set_mix_type
  before_action :set_locale
  before_action :set_stream
  before_action :set_period
  before_action :set_items

  def index
    continuation = self.class.calculate_continuation(@items, @page, @per_page)
    Entry.set_contents_of_enclosures(@items)
    if current_resource_owner.present?
      Entry.set_marks(current_resource_owner, @items)
      Entry.set_marks_of_enclosures(current_resource_owner, @items)
    end
    h = {
      direction:    "ltr",
      continuation: continuation,
      alternate:    [],
      items:        @items,
    }
    if @stream.present?
      h[:updated] = @stream.updated_at.to_time.to_i * 1000
    end
    h[:title] = @title
    render json: h, status: 200
  end

  def set_items
    if @stream.present?
      query  = Mix::Query.new(@period,
                              @type,
                              locale:           @locale,
                              entries_per_feed: entries_per_feed)
      @items = @stream.mix_entries(page: @page, per_page: @per_page, query: query)
    end

    if @items.nil?
      render json: {message: "Not found" }, status: 404
      return
    end
  end
end
