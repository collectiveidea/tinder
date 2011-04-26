$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'rspec'
gem 'activesupport', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']
require 'tinder'
require 'fakeweb'

FakeWeb.allow_net_connect = false

def fixture(name)
  File.read(File.dirname(__FILE__) + "/fixtures/#{name}")
end

def stub_connection(object, &block)
  @stubs ||= Faraday::Adapter::Test::Stubs.new

  object.connection.build do |conn|
    conn.use      Faraday::Request::ActiveSupportJson
    conn.adapter :test, @stubs
    conn.use      Tinder::FaradayResponse::RaiseOnAuthenticationFailure
    conn.use      Faraday::Response::ActiveSupportJson
    conn.use      Tinder::FaradayResponse::WithIndifferentAccess
  end

  block.call(@stubs)
end