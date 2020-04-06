module Types
  class QueryType < Types::BaseObject
    field :current_user, Types::UserType, null: true
  end
end
