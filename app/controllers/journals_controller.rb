class JournalsController < ApplicationController
  before_action :set_journal, only: [:edit, :destroy, :update]
  before_action :set_entries, only: [:edit]
  before_action :require_admin, only: [:new, :create, :destroy, :update]
  def index
    @journals = Journal.order('label ASC').page(params[:page])
  end

  def new
    @journal = Journal.new
  end

  def create
    @journal = Journal.new(journal_params)
    respond_to do |format|
      if @journal.save
        format.html { redirect_to journals_path, notice: 'Journal was successfully created.' }
        format.json { render :show, status: :created, location: @journal }
      else
        format.html { redirect_to journals_path, notice: @journal.errors }
        format.json { render json: @journal.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @journal.destroy
        format.html { redirect_to journals_path, notice: 'Journal was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to journals_path, notice: @journal.errors }
        format.json { render json: @journal.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @journal.update(journal_params)
        format.html { redirect_to journals_path, notice: 'Journal was successfully updated.' }
        format.json { render :show, status: :ok, location: @journal }
      else
        format.html { render :edit }
        format.json { render json: @journal.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_journal
    @journal = Journal.find(params[:id])
  end

  def set_entries
    @journal_entries = @journal.entry_journals.page(params[:page])
  end

  def journal_params
    params.require(:journal).permit(:id, :label, :description)
  end
end
