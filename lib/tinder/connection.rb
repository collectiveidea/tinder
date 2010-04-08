require 'httparty'

# override HTTParty's json parser to return a HashWithIndifferentAccess
module HTTParty
  class Parser
    protected
    def json
      result = Crack::JSON.parse(body)
      if result.is_a?(Hash)
        result = HashWithIndifferentAccess.new(result)
      end
      result
    end
  end
end

module Tinder
  class Connection
    HOST = "campfirenow.com"

    attr_reader :subdomain, :uri, :options
    
    def initialize(subdomain, options = {})
      @subdomain = subdomain
      @options = { :ssl => false }.merge(options)
      @uri = URI.parse("#{@options[:ssl] ? 'https' : 'http' }://#{subdomain}.#{HOST}")
      @token = options[:token]
      
      
      class << self
        include HTTParty
        extend HTTPartyExtensions
        
        headers 'Content-Type' => 'application/json'
      end
      
      base_uri @uri.to_s
      basic_auth token, 'X'
    end
    
    module HTTPartyExtensions
      def perform_request(http_method, path, options) #:nodoc:
        response = super
        raise AuthenticationFailed if response.code == 401
        response
      end
    end
    
    def token
      @token ||= begin
        self.basic_auth(options[:username], options[:password])
        self.get('/users/me.json')['user']['api_auth_token']
      end
    end

    def metaclass
      class << self; self; end
    end

    def method_missing(*args, &block)
      metaclass.send(*args, &block)
    end
    
    # Is the connection to campfire using ssl?
    def ssl?
      uri.scheme == 'https'
    end
    
  end
end
