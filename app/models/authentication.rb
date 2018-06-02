# frozen_string_literal: true

class Authentication < ApplicationRecord
  enum provider: %i[spotify twitter]

  belongs_to :user, foreign_key: "user_id"

  def self.find_by_auth(auth)
    find_by(provider: auth.provider, uid: auth.uid)
  end

  def find_or_create_access_token(application)
    access_token = Doorkeeper::AccessToken.find_or_create_for(
      application,
      user.id,
      "",
      nil,
      true
    )
    {
      access_token: access_token.token,
      token_type:   "bearer",
      created_at:   access_token.created_at
    }
  end

  def update_with_auth(auth)
    case auth.provider
    when "spotify"
      update_with_spotify_auth(auth)
    when "twitter"
      update_with_twitter_auth(auth)
    end
  end

  def update_with_spotify_auth(auth)
    update(name:        auth.info.display_name,
           nickname:    "",
           email:       auth.info.email,
           url:         auth.info.external_urls.spotify,
           image_url:   auth.info.images&.first&.url,
           description: "",
           others:      "",
           credentials: auth.credentials.to_json,
           raw_info:    auth.info.to_json)
  end

  def update_with_twitter_auth(auth)
    update(name:        auth.info.name,
           nickname:    auth.info.nickname,
           email:       auth.info.email,
           url:         auth.info.urls.Twitter,
           image_url:   auth.info.image,
           description: auth.info.description,
           others:      "",
           credentials: auth.credentials.to_json,
           raw_info:    auth.extra.raw_info.to_json)
  end

  def spotify_user
    RSpotify::User.new({
      display_name: name,
      email: email,
      credentials: JSON.parse(credentials),
      info: JSON.parse(raw_info),
    }.with_indifferent_access)
  end
end
