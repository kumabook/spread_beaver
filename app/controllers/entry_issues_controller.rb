# frozen_string_literal: true
class EntryIssuesController < ApplicationController
  before_action :set_entry_issue, only: %i[show edit update destroy]
  before_action :set_entry      , only: %i[show edit update destroy create]
  before_action :set_issue      , only: %i[new show edit update destroy create]
  before_action :set_journal    , only: %i[new show edit update destroy create]
  before_action :require_admin

  def new
    @entry_issue = EntryIssue.new issue_id: params[:issue_id]
  end

  def create
    @entry_issue = EntryIssue.new(entry_issue_params)
    begin
      if @entry_issue.save
        redirect_to(issue_entries_path(@issue))
      else
        redirect_to(issue_entries_path(@issue),
                    notice: @entry_issue.errors.full_messages)
      end
    rescue ActiveRecord::RecordNotUnique => e
      redirect_to new_issue_entry_issue_path(@entry_issue.issue_id), notice: e.message
    end
  end

  def update
    @entry_issue = EntryIssue.find(params[:id])

    if @entry_issue.update(entry_issue_params)
      redirect_to issue_entries_path(@issue)
    else
      redirect_to(issue_entries_path(@issue),
                  notice: @entry_issue.errors.full_messages)
    end
  end

  def destroy
    @entry_issue.destroy
    redirect_to issue_entries_path(@issue)
  end

  private

    def set_entry_issue
      @entry_issue = EntryIssue.find(params[:id])
    end

    def set_entry
      if @entry_issue.present?
        @entry = @entry_issue.entry
      else
        @entry = Entry.find(entry_issue_params[:entry_id])
      end
    end

    def set_issue
      if @entry_issue.present?
        @issue = @entry_issue.issue
      elsif params[:issue_id].present?
        @issue = Issue.find(params[:issue_id])
      else
        @issue = Issue.find(entry_issue_params[:issue_id])
      end
    end

    def set_journal
      @journal = @issue.journal if @issue.present?
    end

    def entry_issue_params
      params.require(:entry_issue).permit(:entry_id, :issue_id, :engagement)
    end
end
