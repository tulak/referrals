module Types
  class MutationType < Types::BaseObject
    field :register, mutation: Mutations::Auth::Register
  end
end
