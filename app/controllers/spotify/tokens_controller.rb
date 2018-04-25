# frozen_string_literal: true
class Spotify::TokensController < ApplicationController
  SPOTIFY_ACCOUNTS_ENDPOINT = URI.parse("https://accounts.spotify.com")
  CLIENT_ID                 = ENV["SPOTIFY_CLIENT_ID"]
  CLIENT_SECRET             = ENV["SPOTIFY_CLIENT_SECRET"]
  CALLBACK_URL              = ENV["SPOTIFY_CALLBACK_URL"]
  ENCRYPTION_SECRET         = "cFJLyifeUJUBFWdHzVbykfDmPHtLKLGzViHW9aHGmyTLD8hGXC"
  AUTH_HEADER               = "Basic " +
                              Base64.strict_encode64("#{CLIENT_ID}:#{CLIENT_SECRET}")
  skip_before_action :require_login
  protect_from_forgery except: %i[swap refresh]
  def swap
    http = Net::HTTP.new(SPOTIFY_ACCOUNTS_ENDPOINT.host,
                         SPOTIFY_ACCOUNTS_ENDPOINT.port)
    http.use_ssl = true
    auth_code    = params[:code]
    request      = Net::HTTP::Post.new("/api/token")
    request.add_field("Authorization", AUTH_HEADER)
    request.form_data = {
      grant_type:   "authorization_code",
      redirect_uri: CALLBACK_URL,
      code:         auth_code
    }
    response = http.request(request)
    if response.code.to_i == 200
      token_data      = JSON.parse(response.body)
      refresh_token   = token_data["refresh_token"]
      encrypted_token = refresh_token.encrypt(:symmetric,
                                              password: ENCRYPTION_SECRET)
      token_data["refresh_token"] = encrypted_token
      render json: token_data, status: 200
    else
      render json: response.body, status: response.code
    end
  end

  def refresh
    http = Net::HTTP.new(SPOTIFY_ACCOUNTS_ENDPOINT.host,
                         SPOTIFY_ACCOUNTS_ENDPOINT.port)
    http.use_ssl = true
    request      = Net::HTTP::Post.new("/api/token")
    request.add_field("Authorization", AUTH_HEADER)
    encrypted_token = params[:refresh_token]
    refresh_token   = encrypted_token.decrypt(:symmetric,
                                              password: ENCRYPTION_SECRET)

    request.form_data = {
      grant_type:    "refresh_token",
      refresh_token: refresh_token
    }

    response = http.request(request)
    render json: response.body, status: response.code
  end
end
