class Transaction < ApplicationRecord
  module Codes
    REFERRALS_BONUS = 'REFERRALS_BONUS'.freeze
    REFERRED_BONUS = 'REFERRED_BONUS'.freeze
  end

  CODES = [Codes::REFERRALS_BONUS, Codes::REFERRED_BONUS]

  validates :code, inclusion: CODES
  validates :amount, numericality: { greater_than: 0 }

  belongs_to :user

  scope :referred_bonus, -> { where(code: Codes::REFERRED_BONUS) }
  scope :referrals_bonus, -> { where(code: Codes::REFERRALS_BONUS) }
end
