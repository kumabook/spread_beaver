module ApplicationHelper
  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do
              concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
              concat message
            end)
    end
    nil
  end

  def thumbnail_path(model)
    if model.is_a?(String)
      model
    elsif model.is_a?(Feed) && model.visualUrl.present?
      model.visualUrl
    elsif model.is_a?(Entry) && model.has_visual?
      model.visual_url
    else
      asset_path('no_image.png')
    end
  end

  def thumbnail_image_tag(model, size = "50x50")
    image_tag(thumbnail_path(model), size: size, alt: "broken image")
  end

  def thumbnail_image_link(model, size = "50x50")
    link_to thumbnail_image_tag(model, size), thumbnail_path(model)
  end
end
