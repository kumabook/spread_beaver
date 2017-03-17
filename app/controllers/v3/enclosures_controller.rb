class V3::EnclosuresController < V3::ApiController
  before_action :doorkeeper_authorize!
  before_action :set_enclosure,  only: [:show]
  before_action :set_enclosures, only: [:list]

  def model_class
    enclosure_class
  end

  def show
    if @enclosure.present?
      render json: @enclosure.as_detail_json, status: 200
    else
      render json: {}, status: :not_found
    end
  end

  def list
    if @enclosures.present?
      render json: @enclosures.map {|t|
        t.as_detail_json
      }.to_json, status: 200
    else
      render json: {}, status: :not_found
    end
  end

  private
    def type
      params[:type]
    end

    def enclosure_class
      type.constantize
    end

    def fetch_contents_method
      "fetch_#{type.downcase.pluralize}".to_sym
    end

    def fetch_content_method
      "fetch_#{type.downcase}".to_sym
    end

    def set_enclosure
      @enclosure = enclosure_class.detail.find(params[:id])
      @content           = PinkSpider.new.public_send fetch_content_method,
                                                      @enclosure.id
      @enclosure.content = @content
    end

    def set_enclosures
      @enclosures = enclosure_class.detail.find(params['_json'])
      @contents = PinkSpider.new.public_send fetch_contents_method,
                                             @enclosures.map {|t| t.id }
      @enclosures.each do |e|
        e.content = @contents.select {|c| c["id"] == e.id }.first
      end
    end
end
