module UserServices
  class ReferralsBonus
    AMOUNT = 10
    MIN_REFERRALS_COUNT = 5
    def self.apply(user)
      self.new(user).apply
    end

    attr_reader :user

    def initialize(user)
      @user = user
    end

    def apply
      ApplicationRecord.transaction do
        user.with_lock do
          return false unless applicable?

          transaction = user.transactions.build(
            code: Transaction::Codes::REFERRALS_BONUS,
            amount: AMOUNT
          )
          transaction.save
        end
      end
    end

    private

    def applicable?
      return false if user.referred_users.count < MIN_REFERRALS_COUNT
      return false if user.transactions.referred_bonus.any?

      true
    end
  end
end