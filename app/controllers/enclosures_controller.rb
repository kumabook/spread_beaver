require('pink_spider')
require('paginated_array')
class EnclosuresController < ApplicationController
  include MarkControllable
  include LikableController
  include SavableController
  include PlayableController
  before_action :set_type
  before_action :set_enclosure      , only: [:show, :destroy, :crawl, :activate, :deactivate]
  before_action :set_content        , only: [:show, :edit]
  before_action :set_entry_and_issue, only: [:index]
  before_action :set_query          , only: [:search]

  def index
    if @entry.present?
      @entry_enclosures = @entry.entry_enclosures
                            .page(params[:page])
      @enclosures = @entry.public_send(index_method)
                          .page(params[:page])
    elsif @issue.present?
      @enclosure_issues = @issue.enclosure_issues
                            .order('engagement DESC')
                            .page(params[:page])
      @enclosures = @issue.public_send(index_method)
                          .order('engagement DESC')
                          .page(params[:page])
    else
      @enclosures = enclosure_class.order('created_at DESC').page(params[:page])
    end

    enclosure_class.set_marks(current_user, @enclosures) if current_user.present?
    enclosure_class.set_contents(@enclosures)
  end

  def search
    per_page    = Kaminari::config::default_per_page
    @enclosures = enclosure_class.search(@query, params[:page], per_page)
    enclosure_class.set_marks(current_user, @enclosures) if current_user.present?
    render :index
  end

  def actives
    per_page    = Kaminari::config::default_per_page
    @enclosures = Playlist.fetch_actives(page: params[:page].to_i, per_page: per_page)
    enclosure_class.set_marks(current_user, @enclosures) if current_user.present?
    enclosure_class.set_contents(@enclosures)
    render :index
  end

  def show
  end

  def new
    @enclosure = enclosure_class.new
  end

  def create
    @enclosure = enclosure_class.create_with_pink_spider(enclosure_params.to_h)
    respond_to do |format|
      if @enclosure.save
        format.html {
          redirect_to view_context.enc_path(@type, @enclosure),
                      notice: "#{enclosure_class.name} #{@enclosure.id} was successfully created."
        }
      else
        format.html { render :new }
      end
    end
  rescue RestClient::NotFound
    flash[:alert] = "Sorry, the resource not found."
    redirect_to view_context.new_enc_path(@type)
  end

  def destroy
    @enclosure.destroy
    respond_to do |format|
      format.html {
        redirect_to view_context.index_enc_path(@type),
                    notice: "#{enclosure_class.name} was successfully destroyed."
      }
    end
  end

  def crawl
    content = @enclosure.fetch_content
    @enclosure.update(created_at: content["published_at"],
                      title:      content["title"],
                      provider:   content["provider"])
    @enclosure.fetch_tracks()
    redirect_back(fallback_location: root_path)
  end

  def update_velocity(velocity)
    @enclosure.update_content({ velocity: velocity })
    redirect_back(fallback_location: root_path)
  end

  def activate
    update_velocity(10.0)
  end

  def deactivate
    update_velocity(0)
  end

  private

    def enclosure_class
      case @type
      when "Track"
        Track
      when "Album"
        Album
      when "Playlist"
        Playlist
      end
    end

    def index_method
      @type.downcase.pluralize.to_sym
    end

    def set_type
      @type = params[:type]
    end

    def set_enclosure
      @enclosure = enclosure_class
                     .eager_load(entries: { feed: [:feed_topics, :topics] })
                     .find(params[:id])
    end

    def set_content
      @content = @enclosure.fetch_content
    end

    def set_entry_and_issue
      @entry = Entry.find(params[:entry_id]) if params[:entry_id].present?
      @issue = Issue.find(params[:issue_id]) if params[:issue_id].present?
    end

    def set_query
      @query = params[:query]
    end

    def user_item_params
      target_id  = params["#{enclosure_class.name.downcase}_id"]
      target_key = "#{enclosure_class.table_name.singularize}_id".to_sym
      {
        :user_id        => current_user.id,
        target_key      => target_id,
        :enclosure_type => enclosure_class.name
      }
    end

    def enclosure_params
      params.require(@type.underscore.to_sym).permit(:id,
                                                     :identifier,
                                                     :provider,
                                                     :owner_id,
                                                     :url)
    end
end
