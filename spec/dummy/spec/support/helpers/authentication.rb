# Returns JWT access token for the resource
# Also, updates the 'token_issued_at' column if configured to invalidate old tokens
def access_token_for_resource(resource, resource_name, expired_token = false)
  JWT.encode(
    {
      "#{resource_name}_id": resource.id,
      exp: expired_token ? token_issued_at : token_expire_at,
      iat: token_issued_at
    },
    Rails.application.secrets.secret_key_base
  )
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

