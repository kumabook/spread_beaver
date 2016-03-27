class V3::StreamsController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_feed, only: [:index]
  before_action :set_global_resource, only: [:index]
  before_action :set_page, only: [:index]

  DEFAULT_PAGINATION = {
    'page' => 1,
    'per_page' => Kaminari::config::default_per_page
  }
  LATEST_ENTRIES_PER_PAGE = 3
  CONTINUATION_SALT       = "continuation_salt"
  DURATION                = 3.days
  def index
    if @resource.nil? && @feed.nil?
      render json: {message: "Not found" }, status: 404
    end
    if @resource.present?
      case @resource
      when :latest
        since    = @newer_than.present? ? @newer_than : DURATION.ago
        @entries = Entry.latest_entries(entries_per_feed: LATEST_ENTRIES_PER_PAGE, since: since)
      when :all
        @subscriptions = current_resource_owner.subscriptions
        @entries = Entry.page(@page)
                        .per(@per_page)
                        .subscriptions(@subscriptions)
      when :popular
        from           = @newer_than.present? ? @newer_than : DURATION.ago
        to             = @older_than.present? ? @older_than : from + DURATION
        @entries = Entry.popular_entries_within_period(from: from, to: to)
      when :saved
        @entries = Entry.page(@page)
                        .per(@per_page)
                        .saved(current_resource_owner.id)
      else
        render json: {}, status: :not_found
      end
    elsif @feed.present?
      @entries = Entry.page(@page)
                      .per(@per_page)
                      .feed(@feed)
    end
    continuation = nil
    if @entries.respond_to?(:total_count)
      if @entries.total_count >= @per_page * @page + 1
        continuation = V3::StreamsController::continuation(@page + 1, @per_page)
      end
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

  def set_feed
    @feed = Feed.find_by(id: CGI.unescape(params[:id])) if params[:id].present?
  end

  def set_global_resource
    str = CGI.unescape params[:id] if params[:id].present?
    if str.match /tag\/global\.latest/
      @resource = :latest
    elsif str.match /tag\/global\.popular/
      @resource = :popular
    elsif str.match /user\/.*\/category\/global\.all/
      @resource = :all
    elsif str.match /user\/.*\/tag\/global\.saved/
      @resource = :saved
    end
  end

  def set_page
    @newer_than = params[:newer_than].present? ? Time.at(params[:newer_than].to_i / 1000) : nil
    @older_than = params[:older_than].present? ? Time.at(params[:older_than].to_i / 1000) : nil
    pagination  = V3::StreamsController::pagination(params[:continuation])
    @page       = pagination['page']
    @per_page   = pagination['per_page']
    @newer_than = pagination['newer_than'] if pagination['newer_than'].present?
    @older_than = pagination['older_than'] if pagination['older_than'].present?
  end

  def self.continuation(page=0, per_page = 20, newer_than = nil, older_than = nil)
    str = {
            page: page,
        per_page: per_page,
      newer_than: newer_than,
      older_than: older_than
    }.to_json
    enc = OpenSSL::Cipher::Cipher.new('aes256')
    enc.encrypt
    enc.pkcs5_keyivgen(CONTINUATION_SALT)
    ((enc.update(str) + enc.final).unpack("H*"))[0].to_s
  rescue
    false
  end

  def self.pagination(str)
    return DEFAULT_PAGINATION if str.nil?
    dec = OpenSSL::Cipher::Cipher.new('aes256')
    dec.decrypt
    dec.pkcs5_keyivgen(CONTINUATION_SALT)
    JSON.parse (dec.update(Array.new([str]).pack("H*")) + dec.final)
  rescue
    return DEFAULT_PAGINATION
  end
end
