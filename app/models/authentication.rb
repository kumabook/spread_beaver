# frozen_string_literal: true

class Authentication < ApplicationRecord
  enum provider: %i[spotify]

  belongs_to :user, foreign_key: "user_id"

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

  def spotify_user
    RSpotify::User.new({
      display_name: name,
      email: email,
      credentials: JSON.parse(credentials),
      info: JSON.parse(raw_info),
    }.with_indifferent_access)
  end
end
