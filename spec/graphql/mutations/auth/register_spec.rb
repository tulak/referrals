require 'rails_helper'

RSpec.describe Mutations::Auth::Register, graphql: true do
  let(:mutation_string) do
    <<-GRAPHQL
      mutation register(
        $email: String!,
        $password: String!,
        $passwordConfirmation: String!
        $referralToken: String
      ) {
        register(
          email: $email,
          password: $password,
          passwordConfirmation: $passwordConfirmation,
          referralToken: $referralToken
        ) {
          success
          errors
          user {
            id
            referralToken
          }
        }
      }
    GRAPHQL
  end


  let(:response) { schema_execute(mutation_string, variables: variables) }
  let(:variables) {
    {
      email: 'new_user@example.com',
      password: password,
      passwordConfirmation: password_confirmation,
      referralToken: referral_token
    }
  }
  let(:referral_token) { nil }
  let(:password) { '12345678' }
  let(:password_confirmation) { password }

  context 'valid registration' do
    let(:password_confirmation) { password }
    it 'works' do
      expect(response.dig('data', 'register', 'errors')).to be_nil
      expect(response.dig('data', 'register', 'success')).to eql true
      expect(User.count).to eql 1
    end

    it 'calls bonus services' do
      expect(UserServices::ReferredBonus).to receive(:apply)
      response
    end
  end

  context 'incorrect password confirmation' do
    let(:password_confirmation) { 'A12345678' }
    it 'fails' do
      expect(response.dig('data', 'register', 'errors')).to be_present
      expect(response.dig('data', 'register', 'success')).to eql false
      expect(User.count).to eql 0
    end
  end

  context 'with valid referralToken' do
    let(:referrer) { create(:user) }
    let(:referral_token) { referrer.referral_token }

    it 'stores referrer association' do
      expect(response.dig('data', 'register', 'success')).to eql true
      new_user_id = response.dig('data', 'register', 'user', 'id')
      new_user = User.find(new_user_id)
      expect(new_user.referrer).to eql referrer
    end

    it 'calls bonus services' do
      expect(UserServices::ReferredBonus).to receive(:apply)
      expect(UserServices::ReferralsBonus).to receive(:apply)
      response
    end
  end

  describe 'both bonuses applied' do
    let(:referrer) { create(:user, email: 'referrer@example.com') }

    def register(referral_token:, n: )
      res = schema_execute(mutation_string,
        variables: {
          email: "registered_user#{n}@example.com",
          password: 'asdf1234',
          passwordConfirmation: 'asdf1234',
          referralToken: referral_token
        }
      )
      res.dig('data','register','user')
    end

    it 'receives both bonuses' do
      subject_user_data = register(referral_token: referrer.referral_token, n: 0)
      subject_user = User.find(subject_user_data['id'])

      (1..5).each do |n|
        register(referral_token: subject_user.referral_token, n: n)
      end

      subject_user.reload
      expect(subject_user.transactions.count).to eql 2
      expect(subject_user.transactions.referred_bonus.first).to be_present
      expect(subject_user.transactions.referrals_bonus.first).to be_present
    end
  end
end