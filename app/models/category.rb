class Category < ApplicationRecord
  include Escapable
  include Stream
  has_many :subscription_categories, dependent: :destroy
  has_many :subscriptions          , through: :subscription_categories

  belongs_to :user

  self.primary_key = :id

  after_initialize :set_id, if: :new_record?
  before_save      :set_id

  def entries_of_stream(page: 1, per_page: nil, since: nil)
    Entry.page(page).per(per_page).category(self)
  end

  private
  def set_id
    self.id = "user/#{user.id}/category/#{label}"
  end
end
