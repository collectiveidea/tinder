$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'spec'
gem 'activesupport', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']
require 'tinder'
require 'fakeweb'

FakeWeb.allow_net_connect = false

def fixture(name)
  File.read(File.dirname(__FILE__) + "/fixtures/#{name}")
end