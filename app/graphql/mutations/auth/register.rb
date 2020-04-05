module Mutations
  module Auth
    class Register < Mutations::BaseMutation
      argument :email, String, required: true
      argument :password, String, required: true
      argument :password_confirmation, String, required: true

      field :success, Boolean, null: false, description: 'Result of the registration process'
      field :errors, [String], null: true

      def resolve(email:, password:, password_confirmation:)
        user = User.new(email: email, password: password, password_confirmation: password_confirmation)
        if user.save
          return { success: true }
        else
          return { success: false, errors: user.errors.full_messages }
        end
      end
    end
  end
end