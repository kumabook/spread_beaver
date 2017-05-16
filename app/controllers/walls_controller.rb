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
    respond_to do |format|
      if @wall.save
        format.html { redirect_to walls_path, notice: 'Wall was successfully created.' }
        format.json { render :show, status: :created, location: @wall }
      else
        format.html { redirect_to journals_path, notice: @wall.errors }
        format.json { render json: @wall.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @resources = @wall.resources.page(params[:page]).order('engagement DESC')
    Resource.set_streams(@resources)
  end

  def update
    @wall = Wall.find(params[:id])
    respond_to do |format|
      if @wall.update(wall_params)
        format.html { redirect_to walls_path, notice: 'Wall was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @wall.destroy
        format.html { redirect_to walls_path, notice: 'Wall was successfully destroyed.' }
      else
        format.html { redirect_to walls_path, notice: @wall.errors }
      end
    end
  end

  private
  def set_wall
    @wall = Wall.find(params[:id])
  end

  def wall_params
    params[:wall].permit(:label, :description)
  end
end
