class Keyword < ApplicationRecord
  include Escapable
  include Stream
  include Mix
  has_many :entry_keywords, dependent: :destroy
  has_many :entries       , through: :entry_keywords

  self.primary_key = :id

  after_initialize :set_id, if: :new_record?
  before_save      :set_id

  def entries_of_stream(page: 1, per_page: nil, since: nil)
    Entry.page(page).per(per_page).keyword(self)
  end

  private
  def set_id
    self.id = "keyword/#{label}"
  end
end
