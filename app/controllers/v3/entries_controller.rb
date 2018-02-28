class V3::EntriesController < V3::ApiController
  before_action :set_entry                , only: [:show]
  before_action :set_entries              , only: [:list]
  before_action :set_cache_control_headers, only: [:show, :list]

  def show
    set_surrogate_key_header @entry.record_key
    if @entry.present?
      render json: @entry.as_detail_json, status: 200
    else
      render_not_found
    end
  end

  def list
    if @entries.present?
      render json: @entries.map {|e|
        e.as_detail_json
      }.to_json, status: 200
    else
      render_not_found
    end
  end

  private

  def set_entry
    @entry = Entry.with_detail.find(params[:id]) if params[:id].present?
    Entry.set_contents_of_enclosures([@entry])
    if current_resource_owner.present?
      Entry.set_marks(current_resource_owner, [@entry])
    end
  end

  def set_entries
    @entries = Entry.with_detail.find(params['_json'])
    Entry.set_contents_of_enclosures(@entries)
    if current_resource_owner.present?
      Entry.set_marks(current_resource_owner, @entries)
      Entry.set_marks_of_enclosures(current_resource_owner, @entries)
    end
  end

end
