module StreamsControllable
  extend ActiveSupport::Concern
  included do
    before_action :set_stream_id      , only: [:show]
    before_action :set_global_resource, only: [:show]
    before_action :set_feed           , only: [:show]
    before_action :set_keyword        , only: [:show]
    before_action :set_tag            , only: [:show]
    before_action :set_journal        , only: [:show]
    before_action :set_topic          , only: [:show]
    before_action :set_category       , only: [:show]
    before_action :set_need_visual    , only: [:show]
    before_action :set_page           , only: [:show]
    before_action :set_provider       , only: [:show]
    before_action :set_locale         , only: [:show]
  end

  class_methods do
    def calculate_continuation(items, page, per_page)
      if items.respond_to?(:total_count)
        if items.total_count >= per_page * page + 1
          return self.continuation(page + 1, per_page)
        end
      end
      return nil
    end
  end

  def set_stream_id
    @stream_id = CGI.unescape params[:id] if params[:id].present?
  end

  def set_feed
    if params[:id].present? && @stream_id.match(/feed\/.*/)
      @feed = Feed.find_by(id: @stream_id)
      @title  = @feed&.title
    end
  end

  def set_keyword
    if params[:id].present? && @stream_id.match(/keyword\/.*/)
      @keyword = Keyword.find_by(id: @stream_id)
      @title  = @keyword&.label
    end
  end

  def set_tag
    if params[:id].present? && @stream_id.match(/user\/.*\/tag\/.*/)
      @tag = Tag.find_by(id: @stream_id)
      @title  = @tag&.label
    end
  end

  def set_journal
    if params[:id].present? && @stream_id.match(/journal\/.*/)
      @journal = Journal.find_by(stream_id: @stream_id)
      @title  = @journal&.label
    end
  end

  def set_topic
    if params[:id].present? && @stream_id.match(/topic\/.*/)
      @topic = Topic.eager_load(:feeds).find_by(id: @stream_id)
      @title  = @topic&.label
    end
  end

  def set_category
    if params[:id].present? && @stream_id.match(/user\/.*\/category\/.*/)
      @category = Category.includes(:subscriptions).find_by(id: @stream_id)
      @title  = @category&.label
    end
  end

  def set_global_resource
    case @stream_id
    when /(tag|playlist)\/global\.latest/
      @resource = :latest
    when /(tag|playlist)\/global\.hot/
      @resource = :hot
    when /(tag|playlist)\/global\.popular/
      @resource = :popular
    when /(tag|playlist)\/global\.featured/
      @resource = :featured
    when /user\/(.*)\/category\/global\.all/
      @resource = :all
      @user     = User.find($1)
    when /user\/(.*)\/(tag|playlist)\/global\.liked/
      @resource = :liked
      @user     = User.find($1)
    when /user\/(.*)\/(tag|playlist)\/global\.saved/
      @resource = :saved
      @user     = User.find($1)
    when /user\/(.*)\/(tag|playlist)\/global\.read/
      @resource = :read
      @user     = User.find($1)
    when /user\/(.*)\/(tag|playlist)\/global\.played/
      @resource = :played
      @user     = User.find($1)
    end
  end

  def set_need_visual
    if @resource.present?
      @need_visual = true
    elsif @topic.present?
      @need_visual = true
    else
      @need_visual = false
    end
  end

  def set_enclosure_class
    case params[:enclosures]
    when 'tracks'
      @enclosure_class = Track
    when 'playlists'
      @enclosure_class = Playlist
    when 'albums'
      @enclosure_class = Album
    end
  end

  def set_period
    from     = @newer_than.present? ? @newer_than : -Float::INFINITY
    to       = @older_than.present? ? @older_than : Float::INFINITY
    @period  = from..to
  end

  def set_stream
    [@feed, @keyword, @tag, @topic, @category].each do |stream|
      if stream.present?
        @stream = stream
        break
      end
    end
    @stream = @journal.current_issue if @journal.present?
  end

  def set_mix_type
    case params[:type]
    when 'hot'
      @type = :hot
    when 'popular'
      @type = :popular
    when 'featured'
      @type = :featured
    when 'picked'
      @type = :picked
    when 'engaging'
      @type = :engaging
    else
      @type = :hot
    end
  end

  def set_locale
    @locale = params[:locale]
    @locale = @locale || "ja" # FIXME after client updates
  end

  def set_provider
    @provider = params[:provider]
  end

  private

  def entries_per_feed
    Setting.latest_entries_per_feed || 3
  end
end
