class Wall < ApplicationRecord
  has_many :resources,
           -> { order("engagement DESC") },
           class_name: Resource, foreign_key: 'wall_id', dependent: :destroy

  def as_json(options = {})
    h              = super(options)
    h['resources'] = resources.as_json
    h
  end
end
