# frozen_string_literal: true
class ResourcesController < ApplicationController
  before_action :set_resource, only: [:show, :edit, :update, :destroy]
  before_action :set_wall
  before_action :require_admin

  def new
    @resource = Resource.new(wall_id: params[:wall_id])
    @wall = @resource.wall
  end

  def create
    @resource = Resource.new(resource_params)
    begin
      if @resource.save
        redirect_to(edit_wall_path(@wall))
      else
        redirect_to(edit_wall_path(@wall),
                    notice: @resource.errors.full_messages)
      end
    rescue ActiveRecord::RecordNotUnique => e
      redirect_to new_wall_item_path(@wall), notice: e.message
    end
  end

  def update
    if @resource.update(resource_params)
      redirect_to edit_wall_path(@wall)
    else
      redirect_to(edit_wall_path(@wall),
                  notice: @wall.errors.full_messages)
    end
  end

  def destroy
    respond_to do |format|
      if @resource.destroy
        format.html {
          redirect_to edit_wall_path(@wall)
        }
      else
        format.html {
          redirect_to edit_wall_path(@wall),
                      notice: @wall.errors
        }
      end
    end
  end

  private

    def set_resource
      @resource = Resource.find(params[:id])
    end

    def set_wall
      if @resource.present?
        @wall = @resource.wall
      elsif params[:wall_id].present?
        @wall = Wall.find(params[:wall_id])
      elsif resource_params[:wall_id].present?
        @wall = Wall.find(resource_params[:wall_id])
      end
    end

    def resource_params
      params.require(:resource).permit(:resource_id,
                                       :resource_type,
                                       :engagement,
                                       :options,
                                       :wall_id)
    end
end
