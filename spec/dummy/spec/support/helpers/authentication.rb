# Returns JWT access token for the resource
# Also, updates the 'token_issued_at' column if configured to invalidate old tokens
def access_token_for_resource(resource, resource_name, expired_token = false)
  [
    JWT.encode(
      {
        "#{resource_name}_id": resource.id,
        exp: expired_token ? token_issued_at : token_expire_at,
        iat: token_issued_at
      },
      Rails.application.secrets.secret_key_base
    ),
    new_refresh_token(resource)
  ]
end

# Generate and return unique refresh token
def uniq_refresh_token
  loop do
    random_token = SecureRandom.urlsafe_base64
    return random_token unless RefreshToken.exists?(token: random_token)
  end
end

# Create a new refresh_token for the current resource
def new_refresh_token(resource)
  return nil unless RabbitApi.generate_refresh_token
  resource.refresh_tokens.create(token: uniq_refresh_token).token
end

def current_time
  @current_time ||= Time.now.utc
end

def token_expire_at
  @expire_at ||= (current_time + 30.minutes).to_i
end

def token_issued_at
  @issued_at ||= current_time.to_i
end

