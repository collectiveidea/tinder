# encoding: UTF-8
require 'spec_helper'

describe Tinder::Connection do
  describe "authentication" do
    it "should raise an exception with bad credentials" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/rooms.json") {[401, {}, "Unauthorized"]}
      end

      connection = Tinder::Connection.new('test', :token => 'foo')
      expect { connection.get('/rooms.json') }.to raise_error(Tinder::AuthenticationFailed)
    end

    it "should raise an exception when an invalid subdomain is specified" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/rooms.json") {[404, {}, "Not found"]}
      end

      connection = Tinder::Connection.new('test', :token => 'foo')
      expect { connection.get('/rooms.json') }.to raise_error(Tinder::AuthenticationFailed)
    end

    it "should lookup token when username/password provided" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/users/me.json") {[200, {}, fixture('users/me.json')]}
      end

      connection = Tinder::Connection.new('test', :username => 'user', :password => 'pass')
      expect(connection.token).to eq("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
    end

    it "should use basic auth for credentials" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/rooms.json") {[200, {}, fixture('rooms.json')]}
      end
      connection = Tinder::Connection.new('test', :token => 'mytoken')
      expect { connection.get('/rooms.json') }.not_to raise_error
    end

  end

  describe "oauth" do
    let (:oauth_token) { "myoauthtoken" }
    let (:connection) { Tinder::Connection.new('test', :oauth_token => oauth_token) }

    before do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/rooms.json") {[200, {}, fixture('rooms.json')]}
      end
    end

    it "should authenticate" do
      expect { connection.get('/rooms.json') }.to_not raise_error
    end

    it "should set the oauth_token" do
      connection.get('/rooms.json')
      expect(connection.options[:oauth_token]).to eq(oauth_token)
    end

    it "should set an Authorization header" do
      connection.get('/rooms.json')
      expect(connection.connection.headers["Authorization"]).to eq("Bearer #{oauth_token}")
    end

  end

  describe "ssl" do
    it "should turn on ssl by default" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/users/me.json") {[200, {}, fixture('users/me.json')]}
      end

      connection = Tinder::Connection.new('test', :username => 'user', :password => 'pass')
      expect(connection.ssl?).to eq(true)
    end

    it "should should allow peer verification to be turned off" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/users/me.json") {[200, {}, fixture('users/me.json')]}
      end

      connection = Tinder::Connection.new('test', :username => 'user', :password => 'pass', :ssl_verify => false)
      expect(connection.connection.ssl.verify?).to eq(false)
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
      expect(connection.connection.ssl.to_hash).to eq(:verify => false, :ca_path => "/usr/lib/ssl/certs", :ca_file => "/etc/ssl/custom")
    end
  end
end
