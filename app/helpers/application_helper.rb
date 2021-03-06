# frozen_string_literal: true

module ApplicationHelper
  def bootstrap_class_for(flash_type)
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(_opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do
               concat content_tag(:button, "x", class: "close", data: { dismiss: "alert" })
               concat message
             end)
    end
    nil
  end

  def score_value(score)
    format("%.2f", score)
  end

  def thumbnail_path(model)
    if model.is_a?(String)
      model
    elsif model.respond_to?(:has_thumbnail?) && model.has_thumbnail?
      model.thumbnail_url
    else
      asset_path("no_image.png")
    end
  end

  def thumbnail_image_tag(model, size = "50x50")
    image_tag(thumbnail_path(model), size: size, alt: "broken image")
  end

  def thumbnail_image_link(model, size = "50x50")
    link_to thumbnail_image_tag(model, size), thumbnail_path(model)
  end

  def sanitize_link(href)
    if href.start_with?("javascript:", "data:")
      ""
    else
      href
    end
  end

  def paginate_for_mix(items, options)
    CGI.unescape paginate(items, options)
  end

  def enc_path(type, item)
    public_send "#{type.underscore}_path".to_sym, item
  end

  def index_enc_path(type)
    public_send "#{type.underscore.pluralize}_path".to_sym
  end

  def likes_path(type, item)
    public_send "#{type.underscore}_likes_path".to_sym, item
  end

  def like_path(type, item)
    public_send "#{type.underscore}_like_path".to_sym, item
  end

  def saves_path(type, item)
    public_send "#{type.underscore}_saves_path".to_sym, item
  end

  def save_path(type, item)
    public_send "#{type.underscore}_save_path".to_sym, item
  end

  def plays_path(type, item)
    public_send "#{type.underscore}_plays_path".to_sym, item
  end

  def new_enc_path(type)
    public_send "new_#{type.underscore}_path".to_sym
  end

  def new_entry_enc_path(type, item)
    public_send "new_entry_#{type.underscore}_path".to_sym, item
  end

  def entry_enc_path(type, entry)
    public_send "entry_#{type}_path".to_sym, entry
  end

  def search_enc_path(type)
    public_send "search_#{type.pluralize.underscore}_path".to_sym
  end

  def crawl_enc_path(type, item)
    public_send "crawl_#{type.underscore}_path".to_sym, item
  end

  def enc_create_identity_path(type, item)
    public_send "create_identity_#{type.underscore}_path".to_sym, item
  end

  def enc_identity_path(type, item)
    public_send "#{type.underscore}_identity_path".to_sym, item
  end

  def provider_icon(provider)
    case provider
    when "Spotify"
      fa_icon "spotify"
    when "AppleMusic"
      fa_icon "itunes-note"
    when "YouTube"
      fa_icon "youtube"
    when "SoundCloud"
      fa_icon "sound-cloud"
    else
      fa_icon "question"
    end
  end

  def fa_icon(name)
    content_tag(:i, nil, class: "fab fa-#{name} fa-lg")
  end
end
