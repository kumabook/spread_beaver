# frozen_string_literal: true
class TagsController < ApplicationController
  before_action :set_tag, only: [:edit, :destroy, :update]
  def index
    @tags = Tag.order("label ASC").all
  end

  def new
    @tag = Tag.new(user: current_user)
  end

  def create
    @tag = Tag.new(tag_params.merge(user: current_user))
    respond_as_create(@tag)
  end

  def destroy
    respond_as_destroy(@tag)
  end

  def update
    respond_as_update(@tag, tag_params)
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:id, :label, :description)
  end
end
