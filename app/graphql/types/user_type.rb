module Types
  class UserType < Types::BaseObject
    field :email, String, null: true
    field :referral_token, String, null: true
  end
end
