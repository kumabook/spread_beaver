# frozen_string_literal: true
class WallsController < ApplicationController
  before_action :set_wall, only: [:edit, :destroy, :update]
  before_action :require_admin, only: [:new, :create, :destroy, :update]
  def index
    @walls = Wall.all.page(params[:page])
  end

  def new
    @wall = Wall.new
  end

  def create
    @wall = Wall.new(wall_params)
    respond_as_create(@wall)
  end

  def edit
    @resources = @wall.resources.page(params[:page]).order('engagement DESC')
    Resource.set_item_of_stream_resources(@resources)
  end

  def update
    @wall = Wall.find(params[:id])
    respond_as_update(@wall, wall_params)
  end

  def destroy
    respond_as_destroy(@wall)
  end

  private
  def set_wall
    @wall = Wall.find(params[:id])
  end

  def wall_params
    params[:wall].permit(:label, :description)
  end
end
