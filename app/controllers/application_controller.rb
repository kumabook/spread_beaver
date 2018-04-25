# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :require_login

  protected
  def admin?
    current_user && current_user.admin?
  end

  def require_admin
    unless admin?
      redirect_to root_path
    end
  end

  private
  def not_authenticated
    redirect_to login_path, alert: "Please login first"
  end

  def respond_as_create(item)
    respond_to do |format|
      if item.save
        format.html { redirect_to index_path(item), notice: "#{item.class.name} was successfully created." }
        format.json { render :show, status: :created, location: item }
      else
        format.html { redirect_to index_path(item), notice: item.errors }
        format.json { render json: item.errors, status: :unprocessable_entity }
      end
    end
  end

  def respond_as_destroy(item)
    respond_to do |format|
      if item.destroy
        format.html { redirect_to index_path(item), notice: "#{item.class.name} was successfully destroyed." }
        format.json { head :no_content }
      else
        format.html { redirect_to index_path(item), notice: item.errors }
        format.json { render json: item.errors, status: :unprocessable_entity }
      end
    end
  end

  def respond_as_update(item, item_params)
    respond_to do |format|
      if item.update(item_params)
        format.html { redirect_to index_path(item), notice: "#{item.class.name} was successfully updated." }
        format.json { render :show, status: :ok, location: item }
      else
        format.html { render "edit" }
        format.json { render json: item.errors, status: :unprocessable_entity }
      end
    end
  end

  def index_path(item)
    public_send "#{item.class.name.downcase.pluralize}_path".to_sym
  end

end
