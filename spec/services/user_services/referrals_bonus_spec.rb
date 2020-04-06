require 'rails_helper'

RSpec.describe UserServices::ReferralsBonus do
  shared_examples_for 'referrals bonnus applied once' do
    it { is_expected.to eql true }
    it 'does create one transaction' do
      subject
      expect(user.transactions.count).to eql 1
      transaction = user.transactions.first
      expect(transaction.code).to eql Transaction::Codes::REFERRALS_BONUS
      expect(transaction.amount).to eql UserServices::ReferralsBonus::AMOUNT
    end
  end

  shared_examples_for 'referrals bonus not applied' do
    it { is_expected.to eql false }
    it 'does not create transaction' do
      expect(user.transactions.count).to eql 0
    end
  end

  subject { described_class.apply_if_applicable(user) }
  let(:user) { create(:user) }

  context 'user without referrals' do
    it_behaves_like 'referrals bonus not applied'
  end

  context 'user with referrals' do
    before do
      referrals_count.times do
        create(:user, referrer: user)
      end
    end

    context 'not enough referrals' do
      let(:referrals_count) { UserServices::ReferralsBonus::MIN_REFERRALS_COUNT - 1 }
      it_behaves_like 'referrals bonus not applied'
    end

    context 'jut enough referrals' do
      let(:referrals_count) { UserServices::ReferralsBonus::MIN_REFERRALS_COUNT }
      it_behaves_like 'referrals bonnus applied once'
    end

    context 'more than enough referrals' do
      let(:referrals_count) { UserServices::ReferralsBonus::MIN_REFERRALS_COUNT + 1 }
      it_behaves_like 'referrals bonnus applied once'
    end
  end
end