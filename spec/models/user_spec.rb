require 'rails_helper'

RSpec.describe User, type: :model do
  context 'referral_token' do
    it 'generates token on create' do
      user = User.create(email: 'test@example.com', password: '123456', password_confirmation: '123456')
      expect(user.referral_token).to be_present
    end
  end
end
