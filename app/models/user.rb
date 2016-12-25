class User < ActiveRecord::Base
  MEMBER = 'Member'
  ADMIN  = 'Admin'
  include Escapable
  include Stream
  has_many :preferences  , dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :categories   , dependent: :destroy
  has_many :saved_entries, dependent: :destroy
  has_many :read_entries , dependent: :destroy
  has_many :tags         , dependent: :destroy
  has_many :likes        , dependent: :destroy
  has_many :tracks       , through: :likes
  authenticates_with_sorcery!

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes["password"] }
  validates :password, confirmation: true, if: -> { new_record? || changes["password"] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes["password"] }

  validates :email, uniqueness: true

  def admin?
    type == ADMIN
  end

  def member?
    type == MEMBER
  end

  def stream_id
    "user_subscription-#{id}"
  end

  def entries_of_stream(page: 1, per_page: nil, since: nil)
    Entry.page(page).per(per_page).subscriptions(Subscription.of(self))
  end

  def as_user_tag
    {
      id: "users/#{id}/category/global.saved",
      label: id # TODO: use picture url or json string or url with query string
    }
  end

  def as_json(options = {})
    super(options.merge({ except: [:crypted_password, :salt] }))
  end

  def to_json(options = {})
    super(options.merge({ except: [:crypted_password, :salt] }))
  end

  def User.delete_cache_of_entries_of_all_user
    Rails.cache.delete_matched("entries_of_user_subscription-*")
  end
end
