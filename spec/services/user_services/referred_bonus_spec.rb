require 'rails_helper'

RSpec.describe UserServices::ReferredBonus do
  subject { described_class.apply(user) }

  context 'user without referrer' do
    let(:user) { create(:user) }

    it { is_expected.to eql false }

    it 'does not create transaction' do
      expect(user.transactions.count).to eql 0
    end
  end

  context 'user with referrer' do
    let(:referrer) { create(:user) }
    let(:user) { create(:user, referrer: referrer) }

    it { is_expected.to eql true }

    it 'does create transaction' do
      subject
      expect(user.transactions.count).to eql 1
      transaction = user.transactions.first
      expect(transaction.code).to eql Transaction::Codes::REFERRED_BONUS
      expect(transaction.amount).to eql UserServices::ReferredBonus::AMOUNT
    end
  end
end