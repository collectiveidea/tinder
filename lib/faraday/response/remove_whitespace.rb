# encoding: UTF-8
require 'faraday'

module Faraday
  class Response::RemoveWhitespace < Response::Middleware
    def parse(body)
      body =~ /^\s+$/ ? "" : body
    end
  end
end
