class Category < ActiveRecord::Base
  include Escapable
  has_many :subscription_categories, dependent: :destroy
  has_many :subscriptions          , through: :subscription_categories

  belongs_to :user

  self.primary_key = :id

  after_initialize :set_id, if: :new_record?
  before_save      :set_id

  private
  def set_id
    self.id = "user/#{user.id}/category/#{label}"
  end
end
