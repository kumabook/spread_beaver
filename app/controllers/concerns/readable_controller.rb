module ReadableController
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  def model_class
    controller_name.classify.constantize
  end

  def read
    respond_to do |format|
      @read = model_class.read_class.new(user_item_params)
      if @read.save
        format.html { redirect_to ({action: :index}), notice: 'Successfully read.' }
        format.json { render :show, status: :created, location: @read }
      else
        format.html { redirect_to ({action: :index}), notice: @read.errors }
        format.json { render json: @read.errors, status: :unprocessable_entity }
      end
    end
  end

  def unread
    respond_to do |format|
      @read = model_class.read_class.find_by(user_item_params)
      if @read.destroy
        format.html { redirect_to ({action: :index}), notice: 'Successfully unread.' }
        format.json { head :no_content }
      else
        format.html { redirect_to ({action: :index}), notice: @read.errors }
        format.json { render json: @read.errors, status: :unprocessable_entity }
      end
    end
  end

  module ClassMethods
  end
end
