# encoding: UTF-8
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rspec'
require 'tinder'
require 'fakeweb'

FakeWeb.allow_net_connect = false

def fixture(name)
  File.read(File.dirname(__FILE__) + "/fixtures/#{name}")
end

def stub_connection(object, &block)
  @stubs ||= Faraday::Adapter::Test::Stubs.new

  object.connection.build do |builder|
    builder.use     FaradayMiddleware::EncodeJson
    builder.use     FaradayMiddleware::Mashify
    builder.use     FaradayMiddleware::ParseJson
    builder.use     Faraday::Response::RemoveWhitespace
    builder.use     Faraday::Response::RaiseOnAuthenticationFailure
    builder.adapter :test, @stubs
  end

  block.call(@stubs)
end
