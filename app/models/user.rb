class User < ActiveRecord::Base
  has_many :subscriptions
  has_many :user_entries
  has_many :likes
  has_many :tracks, through: :likes
  enum type: {
    member: 'Member',
    admin: 'Admin'
  }
  authenticates_with_sorcery!

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes["password"] }
  validates :password, confirmation: true, if: -> { new_record? || changes["password"] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes["password"] }

  validates :email, uniqueness: true

  def as_json(options = {})
    super(options.merge({ except: [:crypted_password, :salt] }))
  end

  def to_json(options = {})
    super(options.merge({ except: [:crypted_password, :salt] }))
  end
end
