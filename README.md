# API Guard

[![Build Status](https://travis-ci.org/Gokul595/api_guard.svg?branch=master)](https://travis-ci.org/Gokul595/api_guard)
[![Maintainability](https://api.codeclimate.com/v1/badges/ced3e74a26a66ed915cb/maintainability)](https://codeclimate.com/github/Gokul595/api_guard/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/ced3e74a26a66ed915cb/test_coverage)](https://codeclimate.com/github/Gokul595/api_guard/test_coverage)


[JSON Web Token (JWT)](https://jwt.io/) based authentication solution with token refreshing & blacklisting for APIs 
built on Rails. 

This is built using [Ruby JWT](https://github.com/jwt/ruby-jwt) gem.

>**In Progress...**

## Table of Contents

* [Installation](#installation)
* [Getting Started](#getting-started)
    * [Configuring Routes](#configuring-routes)
    * [Registration](#registration)
    * [Sign In (Getting JWT access token)](#sign-in-getting-jwt-access-token)
    * [Authenticate API Request](#authenticate-api-request)
    * [Refresh access token](#refresh-access-token)
    * [Change password](#change-password)
    * [Sign out](#sign-out)
    * [Delete Account](#delete-account)
* [Configuration](#configuration)
    * [Default configuration](#default-configuration)
    * [Access token validity](#access-token-validity)
    * [Access token signing secret](#access-token-signing-secret)
    * [Invalidate tokens on password change](#invalidate-tokens-on-password-change)
* [Overriding defaults](#overriding-defaults)
    * [Controllers](#controllers)
    * [Routes](#routes)

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

### Configuring Routes

Add this line to the application routes (`config/routes.rb`) file:

```ruby
api_guard_routes for: 'users'
``` 

This will generate default routes such as sign up, sign in, sign out, token refresh, password change for User.

### Registration

This will create an user and responds with access token, refresh token and access token expiry in the response header.

Example request:

```
# URL
POST "/users/sign_up"

# Request body
{
    "email": "user@apiguard.com",
    "password": "api_password",
    "password_confirmation": "api_password"
}
```

Example response body:

```json
{
    "status": "success",
    "message": "Signed up successfully"
}
```

Example response headers:

```
Access-Token: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1NDY3MDgwMjAsImlhdCI6MTU0NjcwNjIyMH0.F_JM7fUcKEAq9ZxXMxNb3Os-WeY-tuRYQnKXr_bWo5E
Refresh-Token: Iy9s0S4Lf7Xh9MbFFBdxkw
Expire-At: 1546708020
```

The access token will only be valid till the expiry time. After the expiry you need to 
[refresh the token](#refresh-access-token) and get new access token and refresh token.

### Sign In (Getting JWT access token)

This will authenticate the user with email and password and respond with access token, refresh token and access token 
expiry in the response header.

>To make this work, the resource model (here User) should have an `authenticate` method as available in 
[has_secure_password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password). 
You can use [has_secure_password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password) 
or your own logic to authenticate the user in `authenticate` method.

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
    "message": "Signed in successfully"
}
```

Example response headers:

The response headers for this request will be same as [registration API](#registration).

### Authenticate API Request

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

### Refresh access token

Once the access token expires it won't work and the `authenticate_and_set_user` method used in before_action in 
controller will respond with 401 (Unauthenticated). 

To refresh the expired access token and get new access and refresh token you can use this request 
with both access token and request token (which you got in sign in API) in the request header. 

Example request:

```
# URL
POST "/users/tokens"

# Request header
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1NDY3MDgwMjAsImlhdCI6MTU0NjcwNjIyMH0.F_JM7fUcKEAq9ZxXMxNb3Os-WeY-tuRYQnKXr_bWo5E
Refresh-Token: Iy9s0S4Lf7Xh9MbFFBdxkw
```

Example response body:

```json
{
    "status": "success",
    "message": "Token refreshed successfully"
}
```

Example response headers:

The response headers for this request will be same as [registration API](#registration).

### Change password

To change password of an user you can use this request with the access token in the header and new 
password in the body.

By default, changing password will invalidate all old access tokens and refresh tokens generated for this user and 
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

Example response body:

```json
{
    "status": "success",
    "message": "Password changed successfully"
}
```

Example response headers:

The response headers for this request will be same as [registration API](#registration).

### Sign out

You can use this request to sign out an user. This will blacklist the current access token from future use.

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

### Delete account

You can use this request to delete an user. This will delete the user and its associated refresh tokens.

Example request:

```
# URL
DELETE "/users/delete"

# Request header
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1NDY3MDgwMjAsImlhdCI6MTU0NjcwNjIyMH0.F_JM7fUcKEAq9ZxXMxNb3Os-WeY-tuRYQnKXr_bWo5E
```

Example response:

```json
{
    "status": "success",
    "message": "Account deleted successfully"
}
```

## Configuration

To configure the API Guard you need to first create an initializer using

```ruby
rails generate api_guard:initializer
```

This will generate an initializer named **api_guard.rb** in your app **config/initializers** directory with default 
configurations.

### Default configuration

**config/initializers/api_guard.rb**

```ruby
ApiGuard.setup do |config|
  # Validity of the JWT access token
  # Default: 1 day
  config.token_validity = 1.day

  # Secret key for signing (encoding & decoding) the JWT access token
  # Default: 'secret_key_base' from Rails secrets 
  config.token_signing_secret = Rails.application.secrets.secret_key_base

  # Invalidate old tokens on changing the password
  # Default: false
  config.invalidate_old_tokens_on_password_change = false
end
```

### Access token validity

By default, the validity of the JWT access token is 1 day from the creation. Override this by configuring `token_validity`

```ruby
config.token_validity = 1.hour # Set one hour validity for access tokens
```

On accessing the authenticated API with expired access token, API Guard will respond 401 (Unauthenticated) with message 
"Access token expired".

### Access token signing secret

By default, the `secret_key_base` from the Rails secrets will be used for signing (encoding & decoding) the JWT access token.
Override this by configuring `token_signing_secret`

```ruby
config.token_signing_secret = 'my_signing_secret'
```

### Invalidate tokens on password change

By default, API Guard will not invalidate old JWT access tokens on changing password. If you need, you can enable it by 
configuring `invalidate_old_tokens_on_password_change` to `true`.

>**Note:** To make this work, a column named `token_issued_at` with datatype `datetime` is needed in the resource table.

```ruby
config.invalidate_old_tokens_on_password_change = true
```

If your app allows multiple logins then, you must set this value to `true` so that, this prevent access for all logins 
(access tokens) on changing the password.

## Overriding defaults

### Controllers

You can override the default API Guard controllers and customize the code as your need by generating the controllers in 
your app

```ruby
rails generate api_guard:controllers
```

This will generate all default controllers in the directory **app/controllers/api_guard**.

If you have the controllers in directory other than **controllers/api_guard** you need to specify the path in the routes

```ruby
api_guard_routes for: 'users', controller: {
  registration: 'users/registration',
  authentication: 'users/auth'
}
```

>**Available controllers:** registration, authentication, tokens, passwords

### Routes

You can skip specific controller routes generated by API Guard

```ruby
api_guard_routes for: 'users', except: [:registration]
```

Above config will skip registration related API Guard controller routes for the resource user.


You can also specify only the controller routes you need,

```ruby
api_guard_routes for: 'users', only: [:authentication]
```

##### Customizing the routes

To customize the default routes generated by API Guard you can use `api_guard_scope` in the routes.

```ruby
api_guard_routes for: 'users', except: [:registration]

api_guard_scope 'users' do
  post 'account/create' => 'api_guard/registration#create'
  delete 'account/delete' => 'api_guard/registration#destroy'
end
```

Above configuration will replace default registration routes `users/sign_up` & `users/delete` with `account/create` & 
`account/delete`

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

