class KeywordsController < ApplicationController
  before_action :set_keyword, only: [:edit, :destroy, :update]
  before_action :require_admin, only: [:new, :create, :destroy, :update]
  def index
    @keywords = Keyword.order('label ASC').all
  end

  def new
    @keyword = Keyword.new
  end

  def create
    @keyword = Keyword.new(keyword_params)
    respond_to do |format|
      if @keyword.save
        format.html { redirect_to keywords_path, notice: 'Keyword was successfully created.' }
        format.json { render :show, status: :created, location: @keyword }
      else
        format.html { redirect_to keywords_path, notice: @keyword.errors }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @keyword.destroy
        format.html { redirect_to keywords_path, notice: 'Keyword was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to keywords_path, notice: @keyword.errors }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @keyword.update(keyword_params)
        format.html { redirect_to keywords_path, notice: 'Keyword was successfully updated.' }
        format.json { render :show, status: :ok, location: @keyword }
      else
        format.html { render :edit }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_keyword
    @keyword = Keyword.find(params[:id])
  end

  def keyword_params
    params.require(:keyword).permit(:id, :label, :description)
  end
end
