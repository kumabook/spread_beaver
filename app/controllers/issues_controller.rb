class IssuesController < ApplicationController
  before_action :set_issue, only: [:edit, :destroy, :update]
  before_action :set_journal
  before_action :set_entries, only: [:edit]
  before_action :require_admin, only: [:new, :create, :destroy, :update]
  def index
    @issues = Issue.order('label DESC').where(journal: @journal).page(params[:page])
  end

  def new
    @issue = Issue.new
    @issue.journal = @journal
  end

  def create
    @issue = Issue.new(issue_params)
    @issue.journal = @journal
    respond_to do |format|
      if @issue.save
        format.html { redirect_to journal_issues_path(@journal, @issue), notice: 'Issue was successfully created.' }
        format.json { render :show, status: :created, location: @issue }
      else
        format.html { redirect_to journal_issues_path, notice: @issue.errors }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @issue.destroy
        format.html { redirect_to journal_issues_path(@journal), notice: 'Issue was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to journal_issues_path(@journal), notice: @issue.errors }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @issue.update(issue_params)
        format.html { redirect_to journal_issues_path(@journal), notice: 'Issue was successfully updated.' }
        format.json { render :show, status: :ok, location: @issue }
      else
        format.html { render :edit }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_issue
    @issue = Issue.find(params[:id])
  end

  def set_journal
    @journal = Journal.find(params[:journal_id])
  end

  def set_entries
    @issue_entries = @issue.entry_issues.page(params[:page])
  end

  def issue_params
    params.require(:issue).permit(:id, :label, :description, :state, :journal_id)
  end
end
