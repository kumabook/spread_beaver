module SavableController
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  def model_class
    controller_name.classify.constantize
  end

  def save
    respond_to do |format|
      @save = model_class.save_class.new(user_item_params)
      if @save.save
        format.html { redirect_to ({action: :index}), notice: 'Successfully saved.' }
        format.json { render :show, status: :created, location: @save }
      else
        format.html { redirect_to ({action: :index}), notice: @save.errors }
        format.json { render json: @save.errors, status: :unprocessable_entity }
      end
    end
  end

  def unsave
    respond_to do |format|
      @save = model_class.save_class.find_by(user_item_params)
      if @save.destroy
        format.html { redirect_to ({action: :index}), notice: 'Successfully unsaved.' }
        format.json { head :no_content }
      else
        format.html { redirect_to ({action: :index}), notice: @save.errors }
        format.json { render json: @save.errors, status: :unprocessable_entity }
      end
    end
  end

  module ClassMethods
  end
end
