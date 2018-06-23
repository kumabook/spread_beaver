# frozen_string_literal: true

class EnclosureIssuesController < ApplicationController
  before_action :set_enclosure_issue, only: %i[show edit update destroy]
  before_action :set_enclosure      , only: %i[show edit update destroy create]
  before_action :set_issue          , only: %i[new show edit update destroy create]
  before_action :set_journal        , only: %i[new show edit update destroy create]
  before_action :require_admin

  def new
    @enclosure_issue = EnclosureIssue.new(issue_id:       params[:issue_id],
                                          enclosure_type: params[:type])
  end

  def create
    @enclosure_issue = EnclosureIssue.new(enclosure_issue_params)
    begin
      if @enclosure_issue.save
        redirect_to(issue_items_path)
      else
        redirect_to(issue_items_path,
                    notice: @enclosure_issue.errors.full_messages)
      end
    rescue ActiveRecord::RecordNotUnique => e
      redirect_to issue_items_path, notice: e.message
    end
  end

  def update
    @enclosure_issue = EnclosureIssue.find(params[:id])

    if @enclosure_issue.update(enclosure_issue_params)
      redirect_to issue_items_path
    else
      redirect_to(issue_items_path,
                  notice: @enclosure_issue.errors.full_messages)
    end
  end

  def destroy
    @enclosure_issue.destroy
    redirect_to issue_items_path
  end

  private

  def enclosure_class(name)
    [Track, Album, Playlist].find { |clazz|  clazz.name == name }
  end

  def set_enclosure_issue
    @enclosure_issue = EnclosureIssue.find_by(id: params[:id])
    if @enclosure_issue.nil?
      @enclosure_issue = EnclosureIssue.find_by(enclosure_id: params[:id],
                                                issue_id:     params[:issue_id])
    end
  end

  def set_enclosure
    if @enclosure_issue.present?
      @enclosure = @enclosure_issue.enclosure
    else
      clazz = enclosure_class(enclosure_issue_params[:enclosure_type])
      @enclosure = clazz.find(enclosure_issue_params[:enclosure_id])
    end
  end

  def set_issue
    if @enclosure_issue.present?
      @issue = @enclosure_issue.issue
    elsif params[:issue_id].present?
      @issue = Issue.find(params[:issue_id])
    else
      @issue = Issue.find(enclosure_issue_params[:issue_id])
    end
  end

  def set_journal
    @journal = @issue.journal if @issue.present?
  end

  def enclosure_issue_params
    params.require(:enclosure_issue).permit(:enclosure_id,
                                            :enclosure_type,
                                            :issue_id, :engagement)
  end

  def issue_items_path
    public_send("issue_#{@enclosure.class.table_name}_path".to_sym, @issue)
  end
end
