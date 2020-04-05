module GraphqlHelpers
  def schema_execute(query, current_user: nil, variables: {})
    ReferralsSchema.execute(query,
      context: {
        current_user: current_user
      },
      variables: variables
    )
  end
end