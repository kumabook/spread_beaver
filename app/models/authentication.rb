# frozen_string_literal: true

class Authentication < ApplicationRecord
  enum provider: %i[spotify]

  belongs_to :user, foreign_key: "user_id"

  def spotify_user
    RSpotify::User.new({
      display_name: name,
      email: email,
      credentials: JSON.parse(credentials),
      info: JSON.parse(raw_info),
    }.with_indifferent_access)
  end
end
