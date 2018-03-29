class Pick < ApplicationRecord
  include EnclosureMark
  belongs_to :enclosure , counter_cache: :pick_count, touch: true
  belongs_to :container , class_name: "Enclosure", foreign_key: "container_id"

  scope :pick_count, -> {
    group(:enclosure_id).order('count_container_id DESC').count('container_id')
  }

end
