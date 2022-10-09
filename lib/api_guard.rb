# frozen_string_literal: true

require 'api_guard/engine'
require 'api_guard/route_mapper'
require 'api_guard/modules'

module ApiGuard
  autoload :AppSecretKey, 'api_guard/app_secret_key'

  module Test
    autoload :ControllerHelper, 'api_guard/test/controller_helper'
  end

  mattr_accessor :enable_response_headers
  self.enable_response_headers = true

  mattr_accessor :add_domain_for_refresh_token
  self.add_domain_for_refresh_token = nil

  mattr_accessor :enable_response_body
  self.enable_response_body = false

  mattr_accessor :enable_cookies_response
  self.enable_cookies_response = false

  mattr_accessor :token_validity
  self.token_validity = 1.day

  mattr_accessor :refresh_token_validity
  self.refresh_token_validity = 2.weeks

  mattr_accessor :token_signing_secret
  self.token_signing_secret = nil

  mattr_accessor :invalidate_old_tokens_on_password_change
  self.invalidate_old_tokens_on_password_change = false

  mattr_accessor :blacklist_token_after_refreshing
  self.blacklist_token_after_refreshing = false

  mattr_accessor :api_guard_associations
  self.api_guard_associations = {}

  mattr_reader :mapped_resource do
    {}
  end

  def self.setup
    yield self
  end

  def self.map_resource(routes_for, class_name)
    mapped_resource[routes_for.to_sym] = ApiGuard::ResourceMapper.new(routes_for, class_name)
  end
end
