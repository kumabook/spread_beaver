# frozen_string_literal: true

module MarkControllable
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  def model_class
    case controller_name
    when "entries"
      Entry
    when "enclosures"
      enclosure_class
    end
  end

  def mark(mark_class)
    respond_to do |format|
      @mark = model_class.try!(mark_class).new(user_item_params)
      if @mark.save
        format.html { redirect_to ({action: :index}), notice: "Successfully liked." }
        format.json { render :show, status: :created, location: @mark }
      else
        format.html { redirect_to ({action: :index}), notice: @mark.errors }
        format.json { render json: @mark.errors, status: :unprocessable_entity }
      end
    end
  end

  def unmark(mark_class)
    respond_to do |format|
      @mark = model_class.try!(mark_class).find_by(user_item_params)
      if @mark.destroy
        format.html { redirect_to ({action: :index}), notice: "Successfully unliked." }
        format.json { head :no_content }
      else
        format.html { redirect_to ({action: :index}), notice: @mark.errors }
        format.json { render json: @mark.errors, status: :unprocessable_entity }
      end
    end
  end

  module ClassMethods
  end
end
