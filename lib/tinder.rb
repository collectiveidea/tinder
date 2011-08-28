# encoding: UTF-8
require 'tinder/connection'
require 'tinder/campfire'
require 'tinder/room'

module Tinder
  class Error < StandardError; end
  class SSLRequiredError < Error; end
  class AuthenticationFailed < Error; end
  class ListenFailed < Error; end
end
