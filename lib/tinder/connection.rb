require 'httparty'

module Tinder
  class Connection
    HOST = "campfirenow.com"

    attr_reader :subdomain, :uri
    
    def initialize(subdomain, options = {})
      @subdomain = subdomain
      options = { :ssl => false }.merge(options)
      @uri = URI.parse("#{options[:ssl] ? 'https' : 'http' }://#{subdomain}.#{HOST}")

      if options[:proxy]
        uri = URI.parse(options[:proxy])
        @http = Net::HTTP::Proxy(uri.host, uri.port, uri.user, uri.password)
      else
        @http = Net::HTTP
      end
      
      class << self
        include HTTParty

        headers 'Content-Type' => 'application/json'
      end
      
      base_uri @uri.to_s
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
