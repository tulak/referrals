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
end