module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :referral_token, String, null: true
    field :balance, Float, null: false
  end
end
