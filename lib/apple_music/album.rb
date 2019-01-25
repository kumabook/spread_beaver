# frozen_string_literal: true

module AppleMusic
  class Album
    THUMBNAIL_SIZE = "300"
    ARTWORK_SIZE   = "640"
    @@attributes = %i[
      artist_name
      artwork
      content_rating
      copyright
      editorial_notes
      genre_names
      is_complete
      is_single
      name
      record_label
      release_date
      play_params
      track_count
      url
    ]
    @@relationships = %i[
      tracks
      artists
      genres
    ]
    attr_accessor :id, :type, :href
    attr_accessor *@@attributes
    attr_accessor *@@relationships

    def initialize(id, type, href, attributes = {}, relationships = {})
      @id   = id
      @type = type
      @href = href
      @@attributes.each do |attr|
        send("#{attr}=".to_sym, attributes[attr.to_s.camelize(:lower)])
      end
      @@relationships.each do |rel|
        relationship = relationships[rel.to_s.camelize(:lower)]
        next if relationship.nil?
        partial_resources = relationship["data"].map do |h|
          AppleMusic.build_model_instance(h)
        end
        send("#{rel}=".to_sym,  partial_resources)
      end
    end

    def thumbnail_url(w = THUMBNAIL_SIZE, h = THUMBNAIL_SIZE)
      artwork["url"].gsub("{w}", w).gsub("{h}", h)
    end

    def artwork_url(w = ARTWORK_SIZE, h = ARTWORK_SIZE)
      artwork["url"].gsub("{w}", w).gsub("{h}", h)
    end

    def self.find(country, ids)
      case ids
      when Array
        AppleMusic.client.fetch_albums(country, ids)
      when String
        AppleMusic.client.fetch_album(country, ids)
      end
    end

    def self.search(country, terms, limit: 10, offset: 0)
      AppleMusic.client.search(country, terms, limit, offset, ["albums"]).dig("albums", "data")
    end
  end
end
