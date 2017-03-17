module LikableController
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  def model_class
    controller_name.classify.constantize
  end

  def like_params
    target_id  = params["#{model_class.name.downcase}_id"]
    target_key = "#{model_class.table_name.singularize}_id".to_sym
    {
      :user_id        => current_user.id,
      target_key      => target_id,
      :enclosure_type => model_class.name
    }
  end

  def like
    respond_to do |format|
      @like = model_class.like_class.new(like_params)
      if @like.save
        format.html { redirect_to ({action: :index}), notice: 'Successfully liked.' }
        format.json { render :show, status: :created, location: @like }
      else
        format.html { redirect_to ({action: :index}), notice: @like.errors }
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  def unlike
    respond_to do |format|
      @like = model_class.like_class.find_by like_params
      if @like.destroy
        format.html { redirect_to ({action: :index}), notice: 'Successfully unliked.' }
        format.json { head :no_content }
      else
        format.html { redirect_to ({action: :index}), notice: @like.errors }
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  module ClassMethods
  end
end
