class GraphqlWarden
  def initialize(warden)
    @warden = warden
  end

  def authenticate(user)
    @warden.set_user(user)
    @warden.env[Warden::JWTAuth::Hooks::PREPARED_TOKEN_ENV_KEY]
  end
end