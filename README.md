# API Guard

[![Build Status](https://travis-ci.org/Gokul595/api_guard.svg?branch=master)](https://travis-ci.org/Gokul595/api_guard)
[![Maintainability](https://api.codeclimate.com/v1/badges/ced3e74a26a66ed915cb/maintainability)](https://codeclimate.com/github/Gokul595/api_guard/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/ced3e74a26a66ed915cb/test_coverage)](https://codeclimate.com/github/Gokul595/api_guard/test_coverage)


[JSON Web Token (JWT)](https://jwt.io/) based authentication solution with token refreshing & blacklisting for APIs 
built on Rails. 

This is built using [Ruby JWT](https://github.com/jwt/ruby-jwt) gem.

>**In Progress...**


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'api_guard'
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install api_guard
```

## Getting Started

Below steps are provided assuming the model in `User`.

### API Guard Routes

Add this line to the application routes (`config/routes.rb`) file:

```ruby
api_guard_routes for: 'users'
``` 

This will generate default routes such as sign up, sign in, sign out, token refresh, password change for User.

### Sign In (Getting JWT access token)
 
This will authenticate the resource (here User) with email and password and responds with access token, refresh token 
and access token expiry timestamp in response header.

Example request:

```
# URL
POST "/users/sign_in"

# Request body
{
    "email": "user@apiguard.com",
    "password": "api_password"
}
```

Example response body:

```json
{
    "status": "success",
    "data": {
        "id": 1,
        "email": "user@apiguard.com",
        "password_digest": "$2a$10$v1xNT0MfwfSzhzLFtisnNOy/uTcn11llcyn4EYnTWUjlv0WETtWim",
        "created_at": "2018-03-17T14:37:33.184Z",
        "updated_at": "2018-03-17T14:37:33.184Z"
    }
}
```

Example response headers:

```
Access-Token: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1NDY3MDgwMjAsImlhdCI6MTU0NjcwNjIyMH0.F_JM7fUcKEAq9ZxXMxNb3Os-WeY-tuRYQnKXr_bWo5E
Refresh-Token: Iy9s0S4Lf7Xh9MbFFBdxkw
Expire-At: 1546708020
```

The access token will only be valid till the expiry time. After the expiry you need to refresh the token and get new 
access token and refresh token.

### Authenticating API Request

To authenticate the API request just add this before_action in the controller:

```ruby
before_action :authenticate_and_set_user
```

Send the access token got in sign in API in the Authorization header in the API request as below. 
Also, make sure you add "Bearer" before the access token in the header value.

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1NDY3MDgwMjAsImlhdCI6MTU0NjcwNjIyMH0.F_JM7fUcKEAq9ZxXMxNb3Os-WeY-tuRYQnKXr_bWo5E
```

Then, you can get the current authenticated user using below method:

```ruby
current_user
```

and also, using below instance variable:

```ruby
@current_user
```

>**Note:** Replace "_user" with your model name if your model is not User.

### Refreshing access token

Once the access token expires it won't work and the `authenticate_and_set_user` method used in before_action in 
controller will respond with 401 (Unauthenticated). 

To refresh the expired/unexpired access token and get new JWT access token and refresh token you can use this request 
with both access token and request token (which you got in sign in API) in the request header. 

Example request:

```
# URL
POST "/users/tokens"

# Request header
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1NDY3MDgwMjAsImlhdCI6MTU0NjcwNjIyMH0.F_JM7fUcKEAq9ZxXMxNb3Os-WeY-tuRYQnKXr_bWo5E
Refresh-Token: Iy9s0S4Lf7Xh9MbFFBdxkw
```

The response for this request will be same as [sign in API](#sign-in-getting-jwt-access-token).

### Changing password

To change password of a resource (here User) you can use this request with the access token in the header and new 
password in the body.

By default, changing password will invalidate all old access tokens and refresh tokens generated for this resource and 
responds with new access token and refresh token. 

Example request:

```
# URL
PATCH "/users/passwords"

# Request header
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1NDY3MDgwMjAsImlhdCI6MTU0NjcwNjIyMH0.F_JM7fUcKEAq9ZxXMxNb3Os-WeY-tuRYQnKXr_bWo5E

# Request body
{
    "password": "api_password_new",
    "password_confirmation": "api_password_new"
}
```

The response for this request will be same as [sign in API](#sign-in-getting-jwt-access-token).

### Sign out

You can use this request to sign out a resource. This will blacklist the current access token from future use.

Example request:

```
# URL
DELETE "/users/sign_out"

# Request header
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1NDY3MDgwMjAsImlhdCI6MTU0NjcwNjIyMH0.F_JM7fUcKEAq9ZxXMxNb3Os-WeY-tuRYQnKXr_bWo5E
```

Example response:

```json
{
    "status": "success",
    "message": "Signed out successfully"
}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Gokul595/api_guard. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to 
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

You can just:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

