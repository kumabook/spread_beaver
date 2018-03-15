require('pink_spider')
require('paginated_array')
class EnclosuresController < ApplicationController
  include LikableController
  include SavableController
  include PlayableController
  before_action :set_enclosure, only: [:show, :destroy]
  before_action :set_content  , only: [:show, :edit]
  before_action :set_entry    , only: [:index]
  before_action :set_issue    , only: [:index]
  before_action :set_query    , only: [:search]
  before_action :set_view_params

  def model_class
    enclosure_class
  end

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
    items = Playlist.fetch_actives
    @enclosures = PaginatedArray.new(items, items.count)
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
          redirect_to item_path(@enclosure),
                      notice: "#{enclosure_class.name} #{@enclosure.id} was successfully created."
        }
      else
        format.html { render :new }
      end
    end
  end

  def destroy
    @enclosure.destroy
    respond_to do |format|
      format.html {
        redirect_to index_path,
                    notice: "#{enclosure_class.name} was successfully destroyed."
      }
    end
  end

  def activate
    target_id  = params["#{model_class.name.downcase}_id"]
    @enclosure = enclosure_class.find(target_id)
    @enclosure.activate
    redirect_back(fallback_location: root_path)
  end

  def deactivate
    target_id  = params["#{model_class.name.downcase}_id"]
    @enclosure = enclosure_class.find(target_id)
    @enclosure.deactivate
    redirect_back(fallback_location: root_path)
  end

  private

    def type
      params[:type]
    end

    def enclosure_class
      type.constantize
    end

    def index_method
      type.downcase.pluralize.to_sym
    end

    def index_path
      self.public_send "#{type.downcase.pluralize}_path".to_sym
    end

    def item_path(enclosure)
      self.public_send "#{type.downcase}_path".to_sym, enclosure
    end

    def set_enclosure
      @enclosure = enclosure_class.find(params[:id])
    end

    def set_content
      @content           = enclosure_class.fetch_content(@enclosure.id)
      @enclosure.content = @content
    end

    def set_entry
      @entry = Entry.find(params[:entry_id]) if params[:entry_id].present?
    end

    def set_issue
      @issue = Issue.find(params[:issue_id]) if params[:issue_id].present?
    end

    def set_query
      @query = params[:query]
    end

    def user_item_params
      target_id  = params["#{model_class.name.downcase}_id"]
      target_key = "#{model_class.table_name.singularize}_id".to_sym
      {
        :user_id        => current_user.id,
        target_key      => target_id,
        :enclosure_type => model_class.name
      }
    end

    def enclosure_params
      params.require(type.underscore.to_sym).permit(:id,
                                                    :identifier,
                                                    :provider,
                                                    :owner_id,
                                                    :url)
    end

    def set_view_params
      @type       = type
      @index_path = index_path
      @item_path  = item_path @enclosure if @enclosure.present?
    end
end
