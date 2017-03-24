module PlayableController
  extend ActiveSupport::Concern
  def self.included(base)
    base.extend(ClassMethods)
  end

  def model_class
    controller_name.classify.constantize
  end

  def play
    respond_to do |format|
      @play = model_class.play_class.new(user_item_params)
      if @play.save
        format.html { redirect_to ({action: :index}), notice: 'Successfully played.' }
        format.json { render :show, status: :created, location: @play }
      else
        format.html { redirect_to ({action: :index}), notice: @play.errors }
        format.json { render json: @open.errors, status: :unprocessable_entity }
      end
    end
  end

  module ClassMethods
  end
end
