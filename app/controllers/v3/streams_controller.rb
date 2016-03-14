class V3::StreamsController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_feed, only: [:index]
  before_action :set_global_resource, only: [:index]
  before_action :set_page, only: [:index]

  DEFAULT_PAGINATION = {
    'page' => 1,
    'per_page' => Kaminari::config::default_per_page
  }

  CONTINUATION_SALT = "continuation_salt"
  def index
    if @resource.nil? && @feed.nil?
      render json: {message: "Not found" }, status: 404
    end
    if @resource.present?
      case @resource
      when :all
        @subscriptions = current_resource_owner.subscriptions
        @entries = Entry.page(@page)
                        .per(@per_page)
                        .includes(:users)
                        .includes(:tracks)
                        .where(feed: @subscriptions.map { |s| s.feed_id })
      when :saved
        @entries = Entry.page(@page)
                        .per(@per_page)
                        .joins(:users)
                        .includes(:tracks)
                        .where(users: { id: current_resource_owner.id })
      end
    elsif @feed.present?
      @entries = Entry.page(@page)
                      .per(@per_page)
                      .includes(:tracks)
                      .where(feed: @feed)
    end
    total_count = @entries.total_count
    continuation = nil
    if total_count >= @per_page * @page + 1
      continuation = V3::StreamsController::continuation(@page + 1, @per_page)
    end
    h = {
      direction: "ltr",
      continuation: continuation,
      alternate: [],
      items: @entries.map do |en|
        hash = en.as_json
        hash['engagement'] = en.users.size
        hash['tags'] = en.users.map do |u|
          {
            id: "users/#{u.id}/category/global.saved",
            label: u.id # TODO: use picture url or json string or url with query string
          }
        end
        hash['enclosure'] = en.tracks.map do |t|
          query = {
                    id: t.id,
              provider: t.provider,
            identifier: t.identifier,
                 title: t.title,
            likesCount: t.likesCount
          }.to_query
          {
            href: "#{v3_track_url(t)}?#{query}",
            type: "application/json",
          }
        end
        hash
      end
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
    if str.match /global\.all/
      @resource = :all
    elsif str.match /global\.saved/
      @resource = :saved
    end
  end

  def set_page
    pagination = V3::StreamsController::pagination(params[:continuation])
    @page       = pagination['page']
    @per_page   = pagination['per_page']
    @newer_than = pagination['newer_than']
  end

  def self.continuation(page=0, per_page = 20)
    str = {page: page, per_page: per_page}.to_json
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
