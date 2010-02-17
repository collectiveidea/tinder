require 'spec_helper'

describe Tinder::Connection do
  describe "authentication" do
    it "should raise an exception with bad credentials" do
      FakeWeb.register_uri(:get, "http://foo:X@test.campfirenow.com/rooms.json",
        :status => ["401", "Unauthorized"])
      connection = Tinder::Connection.new('test', :token => 'foo')
      lambda { connection.get('/rooms.json') }.should raise_error(Tinder::AuthenticationFailed)
    end
    
    it "should lookup token when username/password provided" do
      FakeWeb.register_uri(:get, "http://user:pass@test.campfirenow.com/users/me.json",
        :body => fixture('users/me.json'), :content_type => "application/json")
      connection = Tinder::Connection.new('test', :username => 'user', :password => 'pass')
      connection.token.should.should == "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    end
    
    
    it "should use basic auth for credentials" do
      FakeWeb.register_uri(:get, "http://mytoken:X@test.campfirenow.com/rooms.json",
        :body => fixture('rooms.json'), :content_type => "application/json")
      connection = Tinder::Connection.new('test', :token => 'mytoken')
      lambda { connection.get('/rooms.json') }.should_not raise_error
    end
  end
  
  
end