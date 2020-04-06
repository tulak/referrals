module Types
  class MutationType < Types::BaseObject
    field :register, mutation: Mutations::Auth::Register
    field :login, mutation: Mutations::Auth::Login
  end
end
