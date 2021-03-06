module UserServices
  class ReferredBonus
    AMOUNT = 10
    def self.apply_if_applicable(user)
      self.new(user).apply_if_applicable
    end

    attr_reader :user

    def initialize(user)
      @user = user
    end

    def apply_if_applicable
      ApplicationRecord.transaction do
        user.with_lock do
          return false unless applicable?

          transaction = user.transactions.build(
            code: Transaction::Codes::REFERRED_BONUS,
            amount: AMOUNT
          )
          transaction.save
        end
      end
    end

    private

    def applicable?
      return false unless user.referrer.present?
      return false if user.transactions.referred_bonus.any?

      true
    end
  end
end