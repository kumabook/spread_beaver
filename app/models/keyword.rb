class Keyword < ActiveRecord::Base
  include Escapable
  has_many :entries, through: :entry_keywords
  has_many :entry_keywords

  self.primary_key = :id

  after_initialize :set_id, if: :new_record?
  before_save      :set_id

  private
  def set_id
    self.id = "keyword/#{label}"
  end
end
