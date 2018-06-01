# frozen_string_literal: true

class User < ApplicationRecord
  include Escapable
  include Stream
  MEMBER = "Member"
  ADMIN  = "Admin"

  has_many :authentications  , dependent: :destroy

  has_many :preferences      , dependent: :destroy
  has_many :subscriptions    , dependent: :destroy
  has_many :categories       , dependent: :destroy
  has_many :tags             , dependent: :destroy

  has_many :liked_entries    , dependent: :destroy
  has_many :saved_entries    , dependent: :destroy
  has_many :read_entries     , dependent: :destroy

  belongs_to :liked_enclosures , polymorphic: true, optional: true
  belongs_to :saved_enclosures , polymorphic: true, optional: true
  belongs_to :played_enclosures, polymorphic: true, optional: true

  has_many   :liked_enclosures , dependent: :destroy
  has_many   :saved_enclosures , dependent: :destroy
  has_many   :played_enclosures, dependent: :destroy

  has_many :liked_tracks    , through:   :liked_enclosures , source: :enclosure, source_type: Track.name
  has_many :liked_albums    , through:   :liked_enclosures , source: :enclosure, source_type: Album.name
  has_many :liked_playlists , through:   :liked_enclosures , source: :enclosure, source_type: Playlist.name

  has_many :saved_tracks    , through:   :saved_enclosures , source: :enclosure, source_type: Track.name
  has_many :saved_albums    , through:   :saved_enclosures , source: :enclosure, source_type: Album.name
  has_many :saved_playlists , through:   :saved_enclosures , source: :enclosure, source_type: Playlist.name

  has_many :played_tracks   , through:   :played_enclosures, source: :enclosure, source_type: Track.name
  has_many :played_albums   , through:   :played_enclosures, source: :enclosure, source_type: Album.name
  has_many :played_playlists, through:   :played_enclosures, source: :enclosure, source_type: Playlist.name

  authenticates_with_sorcery!

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes["password"] }
  validates :password, confirmation: true, if: -> { new_record? || changes["password"] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes["password"] }

  validates :email, uniqueness: true

  def admin?
    type == ADMIN
  end

  def member?
    type == MEMBER
  end

  def stream_id
    "user_subscription-#{id}"
  end

  def entries_of_stream(page: 1, per_page: nil, since: nil)
    Entry.page(page).per(per_page).subscriptions(Subscription.of(self))
  end

  def as_user_tag
    {
      id: "users/#{id}/category/global.saved",
      label: id # TODO: use picture url or json string or url with query string
    }
  end

  def as_json(options = { need_picture_put_url: false })
    hash = super(options.merge({ except: %i[crypted_password salt] }))
    hash["fullName"] = hash["name"]
    hash["created"] = created_at.to_time.to_i * 1000

    if options[:need_picture_put_url]
      key = "profiles/picture/#{id}"
      url = S3_SIGNER.presigned_url(:put_object,
                                    bucket: S3_BUCKET.name,
                                    key:    key,
                                    acl:    "public-read"
                                   )
      hash["picture_put_url"] = url
      hash["picture_url"]     = "https://#{URI(url).host}/#{key}"
    end
    hash
  end

  def self.delete_cache_of_entries_of_all_user
    Rails.cache.delete_matched("entries_of_user_subscription-*")
  end

  def spotify_authentication
    authentications.select(&:spotify?).first
  end

  def connect_with_spotify_account(auth)
    authentication = Authentication.find_or_initialize_by(user_id:  id,
                                                          provider: auth.provider,
                                                          uid:      auth.uid)
    authentication.update_with_spotify_auth(auth)
    authentication
  end
end
