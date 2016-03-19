class V3::EntriesController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_entry, only: [:show]
  before_action :set_entries, only: [:list]

  def show
    if @entry.present?
      render json: @entry.as_detail_json, status: 200
    else
      render json: {}, status: :not_found
    end
  end

  def list
    if @entries.present?
      render json: @entries.map {|e|
        e.as_detail_json
      }.to_json, status: 200
    else
      render json: {}, status: :not_found
    end
  end

  private

  def set_entry
    @entry = Entry.find(params[:id]) if params[:id].present?
  end

  def set_entries
    @entries = Entry.find(params['_json'])
  end

end
