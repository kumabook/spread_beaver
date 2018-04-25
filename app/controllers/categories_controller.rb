# frozen_string_literal: true
class CategoriesController < ApplicationController
  before_action :set_category, only: [:edit, :destroy, :update]
  def index
    @categories = Category.all
  end

  def new
    @category = Category.new(user: current_user)
  end

  def create
    @category = Category.new(category_params.merge(user: current_user))
    respond_as_create(@category)
  end

  def destroy
    respond_as_destroy(@category)
  end

  def update
    respond_as_update(@category, category_params)
  end

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:id, :label)
  end
end
