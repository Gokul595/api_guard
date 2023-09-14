# API Guard

[![Version](https://img.shields.io/gem/v/api_guard.svg?color=green)](https://rubygems.org/gems/api_guard)
[![Build Status](https://github.com/Gokul595/api_guard/workflows/build-master/badge.svg?branch=master)](https://github.com/Gokul595/api_guard/actions?query=workflow%3Abuild-master)
[![Maintainability](https://api.codeclimate.com/v1/badges/ced3e74a26a66ed915cb/maintainability)](https://codeclimate.com/github/Gokul595/api_guard/maintainability)


[JSON Web Token (JWT)](https://jwt.io/) based authentication solution with token refreshing & revocation for APIs 
built on Rails.

This is built using [Ruby JWT](https://github.com/jwt/ruby-jwt) gem. Currently API Guard supports only HS256 algorithm 
for cryptographic signing.

## Table of Contents

* [Installation](#installation)
* [Getting Started](#getting-started)
    * [Creating User model](#creating-user-model)
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
    * [Token refreshing](#token-refreshing)
    * [Token revocation](#token-revocation)
* [Overriding defaults](#overriding-defaults)
    * [Controllers](#controllers)
    * [Routes](#routes)
    * [Adding custom data in JWT token payload](#adding-custom-data-in-jwt-token-payload)
    * [Override finding resource](#override-finding-resource)
    * [Customizing / translating response messages using I18n](#customizing--translating-response-messages-using-i18n)
* [Testing](#testing)
* [Wiki](https://github.com/Gokul595/api_guard/wiki)
    * [Using API Guard with Devise](https://github.com/Gokul595/api_guard/wiki/Using-API-Guard-with-Devise)
* [Contributing](#contributing)
* [License](#license)


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'api_guard'
```

And then execute in your terminal:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install api_guard
```

## Getting Started

Below steps are provided assuming the model in `User`.

### Creating User model

Create a model for User with below command.

```bash
$ rails generate model user name:string email:string:uniq password_digest:string
```

Then, run migration to create the `users` table.

```bash
$ rails db:migrate
```

Add [has_secure_password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password) 
in `User` model for password authentication. 

> Refer [this Wiki](https://github.com/Gokul595/api_guard/wiki/Using-API-Guard-with-Devise#authentication) for configuring API Guard authentication to work with Devise instead of using `has_secure_password`.

```ruby
class User < ApplicationRecord
  has_secure_password
end
```

Then, add `bcrypt` gem in your Gemfile which is used by 
[has_secure_password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password)
for encrypting password and authentication.

```ruby
gem 'bcrypt', '~> 3.1.7'
```

And then execute in your terminal:

```bash
$ bundle install
```

### Configuring Routes

Add this line to the application routes (`config/routes.rb`) file:

```ruby
api_guard_routes for: 'users'
``` 

This will generate default routes such as sign up, sign in, sign out, token refresh, password change for User.

> Refer [this Wiki](https://github.com/Gokul595/api_guard/wiki/Using-API-Guard-with-Devise#routes) for configuring API Guard routes to work with Devise.

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

You can customize the parameters of this API by [overriding the controller](#controllers) code if needed.

### Sign In (Getting JWT access token)

This will authenticate the user with email and password and respond with access token, refresh token and access token 
expiry in the response header.

>To make this work, the resource model (User) should have an `authenticate` method as available in 
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

You can customize the parameters of this API by [overriding the controller](#controllers) code if needed.

### Authenticate API Request

To authenticate the API request just add this before_action in the controller:

```ruby
before_action :authenticate_and_set_user
```

>**Note:** It is possible to authenticate with more than one resource, e.g. `authenticate_and_set_user_or_admin` will permit tokens issued for users or admins.

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

>**Note:** Replace `_user` with your model name if your model is not User.

### Refresh access token

This will work only if token refreshing configured for the resource.
Please see [token refreshing](#token-refreshing) for details about configuring token refreshing.

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

You can use this request to sign out an user. This will revoke the current access token from future use if 
[token revocation](#token-revocation) configured.

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

```bash
$ rails generate api_guard:initializer
```

This will generate an initializer named **api_guard.rb** in your app **config/initializers** directory with default 
configurations.

### Default configuration

**config/initializers/api_guard.rb**

```ruby
ApiGuard.setup do |config|
  # Validity of the JWT access token
  # Default: 1 day
  # config.token_validity = 1.day

  # Validity of the refresh token
  # Default: 2 weeks
  # config.refresh_token_validity = 2.weeks

  # Secret key for signing (encoding & decoding) the JWT access token
  # Default: 'secret_key_base' from Rails secrets 
  # config.token_signing_secret = 'my_signing_secret'

  # Invalidate old tokens on changing the password
  # Default: false
  # config.invalidate_old_tokens_on_password_change = false

  # Revoke JWT access token after refreshing
  # Default: false
  # config.revoke_token_after_refreshing = false
end
```

### Access token validity

By default, the validity of the JWT access token is 1 day from the creation. Override this by configuring `token_validity`

```ruby
config.token_validity = 1.hour # Set one hour validity for access tokens
```

On accessing the authenticated API with expired access token, API Guard will respond 401 (Unauthenticated) with message 
"Access token expired".


### Refresh token validity

By default, the validity of the refresh token is 2 weeks from the creation. Override this by configuring `refresh_token_validity`

```ruby
config.refresh_token_validity = 6.hours # Set six hours validity for refresh tokens
```

On accessing the refresh token API with expired refresh token, API Guard will respond 401 (Unauthenticated) with message 
"Invalid refresh token".

### Access token signing secret

By default, the `secret_key_base` from the Rails secrets will be used for signing (encoding & decoding) the JWT access token.
Override this by configuring `token_signing_secret`

```ruby
config.token_signing_secret = 'my_signing_secret'
```

>**Note:** Avoid committing this token signing secret in your version control (GIT) and always keep this secure. As,
>exposing this allow anyone to generate JWT access token and give full access to APIs. Better way is storing this value
>in environment variable or in encrypted secrets (Rails 5.2+)

### Invalidate tokens on password change

By default, API Guard will not invalidate old JWT access tokens on changing password. If you need, you can enable it by 
configuring `invalidate_old_tokens_on_password_change` to `true`.

>**Note:** To make this work, a column named `token_issued_at` with datatype `datetime` is needed in the resource table.

```ruby
config.invalidate_old_tokens_on_password_change = true
```

If your app allows multiple logins then, you must set this value to `true` so that, this prevent access for all logins 
(access tokens) on changing the password.

### Token refreshing

To include token refreshing in your application you need to create a table to store the refresh tokens.

Use below command to create a model `RefeshToken` with columns to store the token and the user reference

```bash
$ rails generate model refresh_token token:string:uniq user:references expire_at:datetime
```

Then, run migration to create the `refresh_tokens` table

```bash
$ rails db:migrate
```

>**Note:** Replace `user` in the above command with your model name if your model is not User.

After creating model and table for refresh token configure the association in the resource model using
`api_guard_associations` method

```ruby
class User < ApplicationRecord
  api_guard_associations refresh_token: 'refresh_tokens'
  has_many :refresh_tokens, dependent: :delete_all
end
```

If you also have token revocation enabled you need to specify both associations as below

```ruby
api_guard_associations refresh_token: 'refresh_tokens', revoked_token: 'revoked_tokens'
```

### Token revocation

To include token revocation in your application you need to create a table to store the revoked tokens. This will be 
used to revoke a JWT access token from future use. The access token will be revoked on successful sign out of the 
resource.

Use below command to create a model `RevokedToken` with columns to store the token and the user reference

```bash
$ rails generate model revoked_token token:string user:references expire_at:datetime
```

Then, run migration to create the `revoked_tokens` table

```bash
$ rails db:migrate
```

>**Note:** Replace `user` in the above command with your model name if your model is not User.

After creating model and table for revoked token configure the association in the resource model using 
`api_guard_associations` method

```ruby
class User < ApplicationRecord
  api_guard_associations revoked_token: 'revoked_tokens'
  has_many :revoked_tokens, dependent: :delete_all
end
```

If you also have token refreshing enabled you need to specify both associations as below

```ruby
api_guard_associations refresh_token: 'refresh_tokens', revoked_token: 'revoked_tokens'
```

And, as this creates rows in `revoked_tokens` table you need to have a mechanism to delete the expired revoked 
tokens to prevent this table from growing. One option is to have a CRON job to run a task daily that deletes the 
revoked tokens that are expired i.e. `expire_at < DateTime.now`.

**Revocation after refreshing token**

By default, the JWT access token will not be revoked on refreshing the JWT access token. To enable this, you can 
configure it in API Guard initializer as below,

```ruby
config.revoke_token_after_refreshing = true
```

## Overriding defaults

### Controllers

You can override the default API Guard controllers and customize the code as your need by generating the controllers in 
your app

```bash
$ rails generate api_guard:controllers users
```

In above command `users` is the scope of the controllers. If needed, you can replace `users` with your own scope.

This will generate all default controllers for `users` in the directory **app/controllers/users**.

Then, configure this controller in the routes

```ruby
api_guard_routes for: 'users', controller: {
  registration: 'users/registration',
  authentication: 'users/authentication',
  passwords: 'users/passwords',
  tokens: 'users/tokens'
}
```

You can also specify the controllers that you need to generate using `-c` or `--controllers` option.

```bash
$ rails generate api_guard:controllers users -c registration authentication
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

>**Available controllers:** registration, authentication, tokens, passwords

**Customizing the route path:**

You can customize the path of the default routes of the API Guard using the `api_guard_scope` as below,

```ruby
api_guard_routes for: 'users', except: [:registration]

api_guard_scope 'users' do
  post 'account/create' => 'api_guard/registration#create'
  delete 'account/delete' => 'api_guard/registration#destroy'
end
```

Above configuration will replace default registration routes `users/sign_up` & `users/delete` with `account/create` & 
`account/delete`

### Adding custom data in JWT token payload

You can add custom data in the JWT token payload in the format of Hash and use the data after decoding the token on 
every request.

To add custom data, you need to create an instance method `jwt_token_payload` in the resource model as below which 
should return a Hash,

```ruby
class User < ApplicationRecord
  def jwt_token_payload
    { custom_key: 'value' }
  end
end
```

API Guard will add the hash returned by this method to the JWT token payload in addition to the default payload values. 
This data (including default payload values) will be available in the instance variable `@decoded_token` on each request 
if the token has been successfully decoded. You can access the values as below,

```ruby
@decoded_token[:custom_key]
```

### Override finding resource

By default, API Guard will try to find the resource by it's `id`. If you wish to override this default behavior, you can
do it by creating a method `find_resource_from_token` in the specific controller or in `ApplicationController` as you 
need.

**Adding custom logic in addition to the default logic:**
```ruby
def find_resource_from_token(resource_class)
  user = super # This will call the actual method defined in API Guard
  user if user&.active?
end
```

**Using custom query to find the user from the token:**
```ruby
def find_resource_from_token(resource_class)
  resource_id = @decoded_token[:"#{@resource_name}_id"]
  resource_class.find_by(id: resource_id, status: 'active') if resource_id
end
```

This method has an argument `resource_class` which is the class (model) of the current resource (`User`).
This method should return a resource object to successfully authenticate the request or `nil` to respond with 401.

You can also use the [custom data](#adding-custom-data-in-jwt-token-payload) added in the JWT token payload using 
`@decoded_token` instance variable and customize the logic as you need.

### Customizing / translating response messages using I18n

API Guard uses [I18n](https://guides.rubyonrails.org/i18n.html) for success and error messages. You can create your own 
locale file and customize the messages for any language.

```yaml
en:
  api_guard:
    authentication:
      signed_in: 'Signed in successfully'
      signed_out: 'Signed out successfully'
```

You can find the complete list of available keys in this file:
https://github.com/Gokul595/api_guard/blob/master/config/locales/en.yml

## Testing

API Guard comes with helper for creating JWT access token and refresh token for the resource which you can use it for 
testing the controllers of your application.

For using it, just include the helper in your test framework.

**RSpec**

If you're using RSpec as your test framework then include the helper in **spec/rails_helper.rb** file

```ruby
RSpec.configure do |config|
  config.include ApiGuard::Test::ControllerHelper
end
```

**Minitest**

If you're using Minitest as your test framework then include the helper in your test file

```ruby
include ApiGuard::Test::ControllerHelper
```

After including the helper, you can use this method to create the JWT access token and refresh token for the resource

```ruby
jwt_and_refresh_token(user, 'user')
```

Where the first argument is the resource(User) object and the second argument is the resource name which is `user`. 

This method will return two values which is access token and refresh token.

If you need expired JWT access token for testing you can pass the third optional argument value as `true`

```ruby
jwt_and_refresh_token(user, 'user', true)
```

Then, you can set the access token and refresh token in appropriate request header on each test request.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Gokul595/api_guard. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to 
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

