class EntryIssuesController < ApplicationController
  before_action :set_entry_issue, only: [:show, :edit, :update, :destroy]
  before_action :require_admin

  def new
    @entry_issue = EntryIssue.new issue_id: params[:issue_id]
  end

  def create
    @entry_issue = EntryIssue.new(entry_issue_params)

    begin
      if @entry_issue.save
        redirect_to edit_issue_path(@entry_issue.issue)
      else
        redirect_to edit_issue_path(@entry_issue.issue,
                                      notice: @entry_issue.errors.full_messages)
      end
    rescue ActiveRecord::RecordNotUnique => e
      redirect_to new_issue_entry_issue_path(@entry_issue.issue_id, notice: e.message)
    end
  end

  def update
    @entry_issue = EntryIssue.find(params[:id])

    if @entry_issue.update(entry_issue_params)
      redirect_to edit_issue_path(@entry_issue.issue)
    else
      render json: @entry_issue.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @entry_issue.destroy

    redirect_to edit_issue_path(@entry_issue.issue)
  end

  private

    def set_entry_issue
      @entry_issue = EntryIssue.find(params[:id])
    end

    def entry_issue_params
      params.require(:entry_issue).permit(:entry_id, :issue_id, :engagement)
    end
end
