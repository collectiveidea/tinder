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
    
    it 'should allow ca_path to be set' do
      ca_path = "/etc/ssl/custom"
      connection = Tinder::Connection.new('test', :ca_path => ca_path)
      connection.connection.ssl[:ca_path].should == ca_path
    end
    
    it 'should allow ca_file to be set' do
      ca_file = "/etc/ssl/custom"
      connection = Tinder::Connection.new('test', :ca_file => ca_file)
      connection.connection.ssl[:ca_file].should == ca_file
    end
  end
end
