require 'active_support'
require 'active_support/json'

require 'tinder/connection'
require 'tinder/multipart'
require 'tinder/campfire'
require 'tinder/room'

module Tinder
  class Error < StandardError; end
  class SSLRequiredError < Error; end
  class AuthenticationFailed < Error; end
  class ListenFailed < Error; end
end
