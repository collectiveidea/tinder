# encoding: UTF-8
require 'spec_helper'

describe Tinder::Connection do
  describe "authentication" do
    it "should raise an exception with bad credentials" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/rooms.json") {[401, {}, "Unauthorized"]}
      end

      connection = Tinder::Connection.new('test', :token => 'foo')
      lambda { connection.get('/rooms.json') }.should raise_error(Tinder::AuthenticationFailed)
    end

    it "should raise an exception when an invalid subdomain is specified" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/rooms.json") {[404, {}, "Not found"]}
      end

      connection = Tinder::Connection.new('test', :token => 'foo')
      lambda { connection.get('/rooms.json') }.should raise_error(Tinder::AuthenticationFailed)
    end

    it "should lookup token when username/password provided" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/users/me.json") {[200, {}, fixture('users/me.json')]}
      end

      connection = Tinder::Connection.new('test', :username => 'user', :password => 'pass')
      connection.token.should == "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    end

    it "should use basic auth for credentials" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/rooms.json") {[200, {}, fixture('rooms.json')]}
      end
      connection = Tinder::Connection.new('test', :token => 'mytoken')
      lambda { connection.get('/rooms.json') }.should_not raise_error
    end
  end

  describe "ssl" do
    it "should turn on ssl by default" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/users/me.json") {[200, {}, fixture('users/me.json')]}
      end

      connection = Tinder::Connection.new('test', :username => 'user', :password => 'pass')
      connection.ssl?.should be_true
    end

    it "should should allow peer verification to be turned off" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/users/me.json") {[200, {}, fixture('users/me.json')]}
      end

      connection = Tinder::Connection.new('test', :username => 'user', :password => 'pass', :ssl_verify => false)
      connection.connection.ssl[:verify].should be == false
    end

    it "should allow passing any ssl_options to Faraday" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/users/me.json") {[200, {}, fixture('users/me.json')]}
      end
      connection = Tinder::Connection.new('test',
        :username => 'user',
        :password => 'pass',
        :ssl_options => {
          :verify  => false,
          :ca_path => "/usr/lib/ssl/certs",
          :ca_file => "/etc/ssl/custom"
        }
      )
      connection.connection.ssl.should eql(:verify => false, :ca_path => "/usr/lib/ssl/certs", :ca_file => "/etc/ssl/custom")
    end
  end
end
