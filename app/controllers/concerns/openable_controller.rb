module OpenableController
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  def model_class
    controller_name.classify.constantize
  end

  def open_params
    target_id  = params["#{model_class.name.downcase}_id"]
    target_key = "#{model_class.table_name.singularize}_id".to_sym
    {
      :user_id        => current_user.id,
      target_key      => target_id,
      :enclosure_type => model_class.name
    }
  end

  def open
    respond_to do |format|
      @open = model_class.open_class.new(open_params)
      if @open.save
        format.html { redirect_to ({action: :index}), notice: 'Successfully opened.' }
        format.json { render :show, status: :created, location: @ope }
      else
        format.html { redirect_to ({action: :index}), notice: @open.errors }
        format.json { render json: @open.errors, status: :unprocessable_entity }
      end
    end
  end

  def unopen
    respond_to do |format|
      @open = model_class.open_class.find_by open_params
      if @open.destroy
        format.html { redirect_to ({action: :index}), notice: 'Successfully unopened.' }
        format.json { head :no_content }
      else
        format.html { redirect_to ({action: :index}), notice: @open.errors }
        format.json { render json: @open.errors, status: :unprocessable_entity }
      end
    end
  end

  module ClassMethods
  end
end
