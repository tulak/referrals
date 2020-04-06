module Mutations
  module Auth
    class Login < Mutations::BaseMutation
      argument :email, String, required: true
      argument :password, String, required: true

      field :success, Boolean, null: false
      field :jwt, String, null: true
      field :error, String, null: true

      def resolve(email:, password:)
        user = User.where(email: email).first
        return invalid_credentials unless user

        authenticated = user.valid_password?(password)
        return invalid_credentials unless authenticated

        token = context[:warden].authenticate(user)
        if token.present?
          { success: true, jwt: token }
        else
          { success: false, error: 'Failed to retrieve authentication token' }
        end
      end

      private
      def invalid_credentials
        {
          error: I18n.t('devise.failure.invalid', authentication_keys: 'email'),
          success: false
        }
      end
    end
  end
end