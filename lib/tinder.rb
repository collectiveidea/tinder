# encoding: UTF-8
require 'tinder/connection'
require 'tinder/campfire'
require 'tinder/room'
require 'logger'

module Tinder
  class Error < StandardError; end
  class SSLRequiredError < Error; end
  class AuthenticationFailed < Error; end
  class ListenFailed < Error; end

  def self.logger
    @logger ||= Logger.new(ENV['TINDER_LOGGING'] ? STDOUT : nil)
  end

  def self.logger=(logger)
    @logger = logger
  end
end
