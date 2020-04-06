module Mutations
  module Auth
    class Register < Mutations::BaseMutation
      argument :email, String, required: true
      argument :password, String, required: true
      argument :password_confirmation, String, required: true
      argument :referral_token, String, required: false

      field :success, Boolean, null: false, description: 'Result of the registration process'
      field :errors, [String], null: true
      field :user, Types::UserType, null: true

      def resolve(email:, password:, password_confirmation:, referral_token: 'test' )
        user = User.new(
          email: email,
          password: password,
          password_confirmation: password_confirmation,
          referrer: find_referrer(referral_token)
        )
        if user.save
          return { success: true, user: user }
        else
          return { success: false, errors: user.errors.full_messages }
        end
      end

      def find_referrer(referral_token)
        return nil unless referral_token

        User.find_by(referral_token: referral_token)
      end
    end
  end
end