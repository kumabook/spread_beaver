# frozen_string_literal: true

class JournalsController < ApplicationController
  before_action :set_journal, only: %i[edit destroy update]
  before_action :require_admin, only: %i[new create destroy update]
  def index
    @journals = Journal.order("label ASC").page(params[:page])
  end

  def new
    @journal = Journal.new
  end

  def create
    @journal = Journal.new(journal_params)
    respond_as_create(@journal)
  end

  def destroy
    respond_as_destroy(@journal)
  end

  def update
    respond_as_update(@journal, journal_params)
  end

  def set_journal
    @journal = Journal.find(params[:id])
  end

  def journal_params
    params.require(:journal).permit(:id, :label, :description)
  end
end
