
require 'rubygems'
require 'active_support'
require 'net/http'
require 'open-uri'
require 'hpricot'


Dir[File.join(File.dirname(__FILE__), 'tinder/**/*.rb')].sort.each { |lib| require lib }
