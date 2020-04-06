module GraphqlHelpers
  def schema_execute(query, current_user: nil, variables: {}, context: {})
    ReferralsSchema.execute(query,
      context: {
        current_user: current_user,
        **context
      },
      variables: variables
    )
  end
end

RSpec.configure do |config|
  config.include GraphqlHelpers
end