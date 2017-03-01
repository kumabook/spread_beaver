module LikableController
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  def modelClass
    controller_name.classify.constantize
  end

  def like
    likeClass = modelClass.likeClass
    respond_to do |format|
      @like = likeClass.new(like_params.merge(user_id: current_user.id))
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
    likeClass = modelClass.likeClass
    respond_to do |format|
      @like = likeClass.find_by(like_params.merge(user_id: current_user.id))
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
