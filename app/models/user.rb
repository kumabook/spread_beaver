class User < ActiveRecord::Base
  has_many :preferences  , dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :categories   , dependent: :destroy
  has_many :saved_entries, dependent: :destroy
  has_many :read_entries , dependent: :destroy
  has_many :tags         , dependent: :destroy
  has_many :likes        , dependent: :destroy
  has_many :tracks       , through: :likes
  enum type: {
    member: 'Member',
    admin:  'Admin'
  }
  authenticates_with_sorcery!

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes["password"] }
  validates :password, confirmation: true, if: -> { new_record? || changes["password"] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes["password"] }

  validates :email, uniqueness: true


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
end
