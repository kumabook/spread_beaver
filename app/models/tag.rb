class Tag < ActiveRecord::Base
  include Escapable
  include Stream
  has_many :entry_tags, dependent: :destroy
  has_many :entries   , through: :entry_tags

  belongs_to :user

  self.primary_key = :id

  after_initialize :set_id, if: :new_record?
  before_save      :set_id

  def entries_of_stream(page: 1, per_page: nil, since: nil)
    Entry.page(page).per(per_page).tag(self)
  end

  private
  def set_id
    self.id = "user/#{user.id}/tag/#{label}"
  end
end
