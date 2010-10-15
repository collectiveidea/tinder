module Tinder
  module FaradayResponse
    class WithIndifferentAccess < ::Faraday::Response::Middleware
      begin
        require 'active_support/core_ext/hash/indifferent_access'
      rescue LoadError, NameError => error
        self.load_error = error
      end

      def self.register_on_complete(env)
        env[:response].on_complete do |response|
          json = response[:body]
          if json.is_a?(Hash)
            response[:body] = ::HashWithIndifferentAccess.new(json)
          elsif json.is_a?(Array) and json.first.is_a?(Hash)
            response[:body] = json.map{|item| ::HashWithIndifferentAccess.new(item) }
          end
        end
      end
    end

    class RaiseOnAuthenticationFailure < ::Faraday::Response::Middleware
      def self.register_on_complete(env)
        env[:response].on_complete do |response|
          raise AuthenticationFailed if response[:status] == 401
        end
      end
    end
  end
end
