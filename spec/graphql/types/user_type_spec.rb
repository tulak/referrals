require 'rails_helper'

RSpec.describe Types::UserType, graphql: true do
  let(:query_string) do
    <<-GRAPHQL
      query {
        currentUser {
          email
          referralToken
        }
      }
    GRAPHQL
  end

  let(:user) { create(:user) }
  let(:response) { schema_execute(query_string, current_user: user) }

  it 'maps user attributes to type fields' do
    expect(response.dig('errors')).to be_nil
    expect(response.dig('data', 'currentUser', 'email')).to eql user.email
    expect(response.dig('data', 'currentUser', 'referralToken')).to eql user.referral_token
  end
end