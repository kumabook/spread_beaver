require('pink_spider')
class EnclosuresController < ApplicationController
  include LikableController
  before_action :set_enclosure, only: [:show, :destroy]
  before_action :set_content  , only: [:show, :edit]
  before_action :set_entry    , only: [:index]
  before_action :set_view_params

  def model_class
    enclosure_class
  end

  def index
    if @entry.present?
      @enclosures = @entry.public_send(index_method).page(params[:page])
    else
      @enclosures = enclosure_class.order('created_at DESC').page(params[:page])
    end
    @contents = PinkSpider.new.public_send fetch_contents_method,
                                           @enclosures.map {|t| t.id }
    my_likes = LikedEnclosure.where(user_id:      current_user.id,
                                    enclosure_id: @enclosures.map { |t| t.id })
    count = LikedEnclosure.where(enclosure_id: @enclosures.map { |t| t.id })
              .group(:enclosure_id).count('enclosure_id')
    @likes_dic = @enclosures.inject({}) do |h, t|
      h[t] = {
        my: my_likes.to_a.select {|l| t.id == l.enclosure_id }.first,
        count: count.to_a.select {|c| t.id == c[0] }.map {|c| c[1] }.first,
      }
      h
    end
  end

  def show
  end

  def new
    @enclosure = enclosure_class.new
  end

  def create
    @enclosure = enclosure_class.new(enclosure_params)

    respond_to do |format|
      if @enclosure.save
        format.html {
          redirect_to index_path,
                      notice: "#{enclosure_class.name} was successfully created."
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
      self.public_send "#{type.downcase.pluralize}_path".to_sym, enclosure
    end

    def fetch_content_method
      "fetch_#{type.downcase}".to_sym
    end

    def fetch_contents_method
      "fetch_#{type.downcase.pluralize}".to_sym
    end

    def set_enclosure
      @enclosure = enclosure_class.find(params[:id])
    end

    def set_content
      @content           = PinkSpider.new.public_send fetch_content_method,
                                                      @enclosure.id
      @enclosure.content = @content
    end

    def set_entry
      @entry = Entry.find(params[:entry_id]) if params[:entry_id].present?
    end

    def enclosure_params
      params.require(type.underscore.to_sym).permit(:id)
    end

    def set_view_params
      @type       = type
      @index_path = index_path
      @item_path  = item_path @enclosure
    end
end
