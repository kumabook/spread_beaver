# frozen_string_literal: true

module Identity
  extend ActiveSupport::Concern

  included do
    scope :with_content, -> { eager_load(:entries).eager_load(:items) }
    scope :with_detail, -> {
      eager_load(:entries)
        .eager_load(:items)
        .eager_load(:pick_containers)
        .eager_load(:pick_enclosures)
    }
  end

  class_methods do
    def search(query, page, per_page)
      where("name ILIKE ?", "%#{query}%").page(page).per(per_page)
    end

    def identity?
      true
    end
  end

  def title
    name
  end

  def thumbnail_url
    items.first&.thumbnail_url
  end
end
