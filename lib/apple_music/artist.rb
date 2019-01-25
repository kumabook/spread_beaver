# frozen_string_literal: true

module AppleMusic
  class Artist
    THUMBNAIL_SIZE = "300"
    ARTWORK_SIZE   = "640"
    @attributes = %i[
      genre_names
      editorial_notes
      name
      url
    ]
    @relationships = %i[
      albums
      genres
    ]
    attr_accessor :id, :type, :href

    class << self
      attr_accessor :attributes
      attr_accessor :relationships
    end

    def initialize(id, type, href, attributes = nil, relationships = nil)
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

    def thumbnail_url(w = ARTWORK_SIZE, h = ARTWORK_SIZE)
      albums&.first&.thumbnail_url(w, h)
    end

    def artwork_url(w = ARTWORK_SIZE, h = ARTWORK_SIZE)
      albums&.first&.thumbnail_url(w, h)
    end

    def self.find(country, ids)
      case ids
      when Array
        AppleMusic.client.fetch_artists(country, ids)
      when String
        AppleMusic.client.fetch_artist(country, ids)
      end
    end

    def self.search(country, terms, limit: 10, offset: 0)
      AppleMusic.client.search(country, terms, limit, offset, ["artists"]).dig("artists", "data")
    end
  end
end
