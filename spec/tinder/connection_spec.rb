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
      connection.token.should.should == "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    end


    it "should use basic auth for credentials" do
      stub_connection(Tinder::Connection) do |stub|
        stub.get("/rooms.json") {[200, {}, fixture('rooms.json')]}
      end
      connection = Tinder::Connection.new('test', :token => 'mytoken')
      lambda { connection.get('/rooms.json') }.should_not raise_error
    end
  end
end
