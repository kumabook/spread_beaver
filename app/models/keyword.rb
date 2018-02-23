class Keyword < ApplicationRecord
  include Escapable
  include Stream
  include Mix
  has_many :entry_keywords, dependent: :destroy
  has_many :entries       , through: :entry_keywords

  self.primary_key = :id

  after_initialize :set_id, if: :new_record?
  before_save      :set_id

  after_create :purge_all
  after_destroy :purge_all
  after_save :purge

  private
  def set_id
    self.id = "keyword/#{label}"
  end
end
