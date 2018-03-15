class Pick < ApplicationRecord
  include EnclosureMark
  has_many   :enclosures, class_name: "Enclosure", foreign_key: "enclosure_id"
  belongs_to :enclosure , class_name: "Enclosure", foreign_key: "container_id"

  scope :pick_count, -> {
    group(:enclosure_id).order('count_container_id DESC').count('container_id')
  }

end
