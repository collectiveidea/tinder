require 'faraday'

module Faraday
  class Response::RaiseOnAuthenticationFailure < Response::Middleware
    def on_complete(response)
      raise Tinder::AuthenticationFailed if response[:status] == 401
    end
  end
end
