require 'faraday'

module Tinder
  class Connection
    HOST = "campfirenow.com"

    attr_reader :subdomain, :uri, :options
    
    def self.connection
      @connection ||= Faraday::Connection.new do |conn|
        conn.use      Faraday::Request::ActiveSupportJson
        conn.adapter  Faraday.default_adapter
        conn.use      Tinder::FaradayResponse::RaiseOnAuthenticationFailure
        conn.use      Faraday::Response::ActiveSupportJson
        conn.use      Tinder::FaradayResponse::WithIndifferentAccess

        conn.headers['Content-Type'] = 'application/json'
        conn.proxy ENV['HTTP_PROXY']
      end
    end

    def initialize(subdomain, options = {})
      @subdomain = subdomain
      @options = { :ssl => true, :proxy => ENV['HTTP_PROXY'] }.merge(options)
      @uri = URI.parse("#{@options[:ssl] ? 'https' : 'http' }://#{subdomain}.#{HOST}")
      @token = options[:token]
      
      connection.basic_auth token, 'X'
    end
    
    def basic_auth_settings
      { :username => token, :password => 'X' }
    end

    def connection
      @connection ||= begin
        conn = self.class.connection.dup
        puts "Setting to: #{@uri.to_s}"
        conn.url_prefix = @uri.to_s
        conn
      end
    end
    
    def token
      @token ||= begin
        connection.basic_auth(options[:username], options[:password])
        get('/users/me.json')['user']['api_auth_token']
      end
    end

    def get(url, *args)
      response = connection.get(url, *args)
      response.body
    end

    def post(url, body = nil, *args)
      response = connection.post(url, body, *args)
      response.body
    end

    def put(url, body = nil, *args)
      response = connection.put(url, body, *args)
      response.body
    end

    # Is the connection to campfire using ssl?
    def ssl?
      uri.scheme == 'https'
    end
  end
end
