class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  before_create :generate_referral_token

  belongs_to :referrer, class_name: 'User', optional: true
  has_many :transactions
  has_many :referred_users, class_name: 'User', foreign_key: :referrer_id

  def balance
    transactions.sum(:amount)
  end

  private

  def generate_referral_token
    self.referral_token = SecureRandom.hex
  end
end
