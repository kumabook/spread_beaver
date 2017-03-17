module LikableController
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  def model_class
    controller_name.classify.constantize
  end

  def like
    respond_to do |format|
      @like = model_class.like_class.new(user_item_params)
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
      @like = model_class.like_class.find_by(user_item_params)
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
