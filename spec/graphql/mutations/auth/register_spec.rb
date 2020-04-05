require 'rails_helper'

RSpec.describe Mutations::Auth::Register, graphql: true do
  let(:mutation_string) do
    <<-GRAPHQL
      mutation register($email: String!, $password: String!, $passwordConfirmation: String!) {
        register(email: $email, password: $password, passwordConfirmation: $passwordConfirmation) {
          success
          errors
        }
      }
    GRAPHQL
  end


  let(:response) { schema_execute(mutation_string, variables: variables) }
  let(:response_errors) { response.dig('errors') }
  let(:variables) { { email: 'test1@example.com', password: password, passwordConfirmation: password_confirmation } }

  context 'valid registration' do
    let(:password) { '12345678' }
    let(:password_confirmation) { password }
    it 'works' do
      expect(response.dig('data', 'register', 'errors')).to be_nil
      expect(response.dig('data', 'register', 'success')).to eql true
      expect(User.count).to eql 1
    end
  end

  context 'incorrect password confirmation' do
    let(:password) { '12345678' }
    let(:password_confirmation) { 'A12345678' }
    it 'fails' do
      expect(response.dig('data', 'register', 'errors')).to be_present
      expect(response.dig('data', 'register', 'success')).to eql false
      expect(User.count).to eql 0
    end
  end
end