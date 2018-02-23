class V3::EnclosuresController < V3::ApiController
  before_action :set_enclosure_class      , only: [:show, :list]
  before_action :set_enclosure            , only: [:show]
  before_action :set_enclosures           , only: [:list]
  before_action :set_cache_control_headers, only: [:show, :list]

  def show
    set_surrogate_key_header @enclosure.record_key
    if @enclosure.present?
      render json: @enclosure.as_detail_json, status: 200
    else
      render_not_found
    end
  end

  def list
    set_surrogate_key_header @enclosure_class.table_key, @enclosures.map(&:record_key)
    if @enclosures.present?
      render json: @enclosures.map {|t|
        t.as_detail_json
      }.to_json, status: 200
    else
      render_not_found
    end
  end

  private
    def set_enclosure
      @enclosure = @enclosure_class.detail.find(params[:id])
      @enclosure_class.set_contents([@enclosure])
      if current_resource_owner.present?
        @enclosure_class.set_marks(current_resource_owner, [@enclosure])
      end
    end

    def set_enclosures
      @enclosures = @enclosure_class.detail.find(params['_json'])
      @enclosure_class.set_contents(@enclosures)
      if current_resource_owner.present?
        @enclosure_class.set_marks(current_resource_owner, @enclosures)
      end
    end

    def set_enclosure_class
      @enclosure_class = params[:type].constantize
    end

end
