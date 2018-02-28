class Wall < ApplicationRecord
  has_many :resources, -> { order("engagement DESC") }, dependent: :destroy

  after_create :purge_all
  after_destroy :purge_all
  after_save :purge
  after_touch :purge

  def as_json(options = {})
    h              = super(options)
    h['resources'] = resources.as_json
    h
  end
end
