# frozen_string_literal: true

class Keyword < ApplicationRecord
  include Escapable
  include Stream
  include Mix
  has_many :keywordables, dependent: :destroy
  has_many :entries          , through: :keywordables, source: :keywordable, source_type: "Entry"
  has_many :track_identities , through: :keywordables, source: :keywordable, source_type: "TrackIdentity"
  has_many :albums_identities, through: :keywordables, source: :keywordable, source_type: "AlbumIdentity"
  has_many :artist_identities, through: :keywordables, source: :keywordable, source_type: "ArtistIdentity"
  has_many :playlists        , through: :keywordables, source: :keywordable, source_type: "Playlist"

  self.primary_key = :id

  after_initialize :set_id, if: :new_record?
  before_save      :set_id

  after_create :purge_all
  after_destroy :purge_all
  after_save :purge

  private

  def set_id
    self.id = "keyword/#{label}"
  end
end
