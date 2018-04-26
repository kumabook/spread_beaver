# frozen_string_literal: true
class Tag < ApplicationRecord
  include Escapable
  include Stream
  include Mix
  has_many :entry_tags, dependent: :destroy
  has_many :entries   , through: :entry_tags

  belongs_to :user

  self.primary_key = :id

  after_initialize :set_id, if: :new_record?
  before_save      :set_id

  private

  def set_id
    self.id = "user/#{user.id}/tag/#{label}"
  end
end
