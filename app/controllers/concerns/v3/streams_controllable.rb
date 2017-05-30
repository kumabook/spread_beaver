module V3::StreamsControllable
  extend ActiveSupport::Concern
  included do
    before_action :set_stream_id      , only: [:index]
    before_action :set_global_resource, only: [:index]
    before_action :set_feed           , only: [:index]
    before_action :set_keyword        , only: [:index]
    before_action :set_tag            , only: [:index]
    before_action :set_journal        , only: [:index]
    before_action :set_topic          , only: [:index]
    before_action :set_category       , only: [:index]
    before_action :set_need_visual    , only: [:index]
    before_action :set_page           , only: [:index]
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
    end
  end

  def set_keyword
    if params[:id].present? && @stream_id.match(/keyword\/.*/)
      @keyword = Keyword.find_by(id: @stream_id)
    end
  end

  def set_tag
    if params[:id].present? && @stream_id.match(/user\/.*\/tag\/.*/)
      @tag = Tag.find_by(id: @stream_id)
    end
  end

  def set_journal
    if params[:id].present? && @stream_id.match(/journal\/.*/)
      @journal = Journal.find_by(stream_id: @stream_id)
    end
  end

  def set_topic
    if params[:id].present? && @stream_id.match(/topic\/.*/)
      @topic = Topic.eager_load(:feeds).find_by(id: @stream_id)
    end
  end

  def set_category
    if params[:id].present? && @stream_id.match(/user\/.*\/category\/.*/)
      @category = Category.includes(:subscriptions).find_by(id: @stream_id)
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
end
