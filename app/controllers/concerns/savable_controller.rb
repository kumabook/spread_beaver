module SavableController
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  def model_class
    controller_name.classify.constantize
  end

  def save_params
    target_id  = params["#{model_class.name.downcase}_id"]
    target_key = "#{model_class.table_name.singularize}_id".to_sym
    {
      :user_id        => current_user.id,
      target_key      => target_id,
      :enclosure_type => model_class.name
    }
  end

  def save
    save_class = model_class.save_class
    respond_to do |format|
      @save = save_class.new(save_params)
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
    save_class = model_class.save_class
    respond_to do |format|
      @save = save_class.find_by save_params
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
