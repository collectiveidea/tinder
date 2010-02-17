require 'active_support'

require 'tinder/connection'
require 'tinder/multipart'
require 'tinder/campfire'
require 'tinder/room'

module Tinder
  class Error < StandardError; end
  class SSLRequiredError < Error; end
  class AuthenticationFailed < Error; end
end
