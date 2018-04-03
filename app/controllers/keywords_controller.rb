class KeywordsController < ApplicationController
  before_action :set_keyword, only: [:edit, :destroy, :update]
  before_action :require_admin, only: [:new, :create, :destroy, :update]
  def index
    @keywords = Keyword.order('label ASC').page(params[:page])
  end

  def new
    @keyword = Keyword.new
  end

  def create
    @keyword = Keyword.new(keyword_params)
    respond_as_create(@keyword)
  end

  def destroy
    respond_as_destroy(@keyword)
  end

  def update
    respond_as_update(@keyword, keyword_params)
  end

  def set_keyword
    @keyword = Keyword.find(params[:id])
  end

  def keyword_params
    params.require(:keyword).permit(:id, :label, :description)
  end
end
