class TagsController < ApplicationController
  before_action :set_tag, only: [:edit, :destroy, :update]
  def index
    @tags = Tag.order('label DESC').all
  end

  def new
    @tag = Tag.new(user: current_user)
  end

  def create
    @tag = Tag.new(tag_params.merge(user: current_user))
    respond_to do |format|
      if @tag.save
        format.html { redirect_to tags_path, notice: 'Tag was successfully created.' }
        format.json { render :show, status: :created, location: @tag }
      else
        format.html { redirect_to tags_path, notice: @tag.errors }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @tag.destroy
        format.html { redirect_to tags_path, notice: 'Tag was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to tags_path, notice: @tag.errors }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to tags_path, notice: 'Tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @tag }
      else
        format.html { render :edit }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:id, :label, :description)
  end
end
