# frozen_string_literal: true
class V3::TagsController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_tag    , only: [:update]
  before_action :set_entry  , only: [:tag_entry]
  before_action :set_entries, only: %i[tag_entries untag_entries]
  before_action :set_tags   , only: %i[tag_entry tag_entries untag_entries destroy]

  def index
    @tags = Tag.order("label ASC").all
    render json: @tags.to_json, status: 200
  end

  def update
    if @tag.update(label: params[:label],
             description: params[:description])
      render json: @tag.to_json, status: 200
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def tag_entry
    if @entry.update(tags: @entry.tags + @tags)
      render json: {}, status: 200
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def tag_entries
    @entries.each do |entry|
      entry.update(tags: entry.tags + @tags)
    end
    render json: {}, status: 200
  end

  def untag_entries
    @entries.each do |entry|
      entry.update(tags: entry.tags - @tags)
    end
    render json: {}, status: 200
  end

  def destroy
    @tags.each(&:destroy)
    render json: {}, status: 200
  end

  private

  def set_tag
    @tag = Tag.find(CGI.unescape params[:id])
  end

  def set_tags
    @tags = []
    if params[:tag_ids].present?
      @tags = params[:tag_ids].split(",").map do |id|
        Tag.find(CGI.unescape id)
      end
    end
  end

  def set_entry
    @entry = Entry.find(CGI.unescape params[:entryId])
  end

  def set_entries
    @entries = []
    if params[:entry_ids].present?
      @entries = params[:entry_ids].split(",").map do |id|
        Entry.find(CGI.unescape id)
      end
    end
  end
end
