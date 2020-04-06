require 'rails_helper'

RSpec.describe Mutations::Auth::Login, graphql: true do
  let(:password) { '12345678' }
  let!(:user) { create(:user, password: password, password_confirmation: password)}

  let(:mutation_string) do
    <<-GRAPHQL
      mutation login($email: String!, $password: String!) {
        login(email: $email, password: $password) {
          success
          jwt
          error
        }
      }
    GRAPHQL
  end

  let(:warden) { double('warden') }
  let(:response) { schema_execute(mutation_string, variables: variables, context: { warden: warden }) }
  let(:response_errors) { response.dig('errors') }
  let(:variables) { { email: user.email, password: login_password } }
  before { allow(warden).to receive(:authenticate).with(user).and_return('xyz') }

  context 'correct credentials' do
    let(:login_password) { password }
    it 'authenticates properly' do
      expect(response.dig('errors')).to be_nil
      expect(response.dig('data', 'login', 'error')).to be_nil
      expect(response.dig('data', 'login', 'success')).to eql true
      expect(response.dig('data', 'login', 'jwt')).to eql 'xyz'
      expect(warden).to have_received(:authenticate).with(user)
    end
  end

  context 'incorrect password confirmation' do
    let(:login_password) { 'other-password' }
    it 'fails' do
      expect(response.dig('errors')).to be_nil
      expect(response.dig('data', 'login', 'error')).to be_present
      expect(response.dig('data', 'login', 'success')).to eql false
      expect(response.dig('data', 'login', 'jwt')).to be_nil
      expect(warden).not_to have_received(:authenticate).with(user)
    end
  end
end