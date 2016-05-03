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

  def thumbnail_image_tag(model, size = "50x50")
    if model.is_a?(String)
      image_tag(model, size: size)
    elsif model.is_a?(Feed) && model.visualUrl.present?
      image_tag(model.visualUrl, size: size)
    elsif model.is_a?(Entry) && model.has_visual?
      image_tag(model.visual_url, size: size)
    else
      image_tag(asset_path('no_image.png'), size: size)
    end
  end
end
