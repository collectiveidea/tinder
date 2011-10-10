# encoding: UTF-8
require 'faraday'

module Faraday
  class Response::RaiseOnAuthenticationFailure < Response::Middleware
    def on_complete(response)
      raise Tinder::AuthenticationFailed if [401, 404].include?(response[:status])
    end
  end
end
