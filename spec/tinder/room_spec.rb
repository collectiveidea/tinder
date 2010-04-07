require 'spec_helper'

describe Tinder::Room do
  before do
    FakeWeb.register_uri(:get, "http://mytoken:X@test.campfirenow.com/room/80749.json",
      :body => fixture('rooms/show.json'), :content_type => "application/json")
    @room = Tinder::Room.new(Tinder::Connection.new('test', :token => 'mytoken'), 'id' => 80749)
  end
  
  describe "join" do
    FakeWeb.register_uri(:post, "http://mytoken:X@test.campfirenow.com/room/80749/join.json", :status => '200')
    
    it "should post to join url" do
      @room.join
    end
  end

  describe "leave" do
    before do
      FakeWeb.register_uri(:post, "http://mytoken:X@test.campfirenow.com/room/80749/leave.json", :status => '200')
    end
    
    it "should post to leave url" do
      @room.leave
    end
  end
  
  describe "lock" do
    before do
      FakeWeb.register_uri(:post, "http://mytoken:X@test.campfirenow.com/room/80749/lock.json", :status => '200')
    end
    
    it "should post to lock url" do
      @room.lock
    end
  end
  
  describe "unlock" do
    before do
      FakeWeb.register_uri(:post, "http://mytoken:X@test.campfirenow.com/room/80749/unlock.json", :status => '200')
    end
    
    it "should post to unlock url" do
      @room.unlock
    end
  end
  
  describe "guest_url" do
    it "should use guest_invite_code if active" do
      @room.stub!(:guest_access_enabled? => true, :guest_invite_code => '123')
      @room.guest_url.should == "http://test.campfirenow.com/123"
    end
    
    it "should return nil when guest access is not enabled" do
      @room.stub!(:guest_access_enabled?).and_return(false)
      @room.guest_url.should be_nil
    end
  end
  
  it "should set guest_invite_code" do
    @room.guest_invite_code.should == "90cf7"
  end
  
  it "should set guest_access_enabled?" do
    @room.guest_access_enabled?.should be_true
  end
  
  describe "name=" do
    it "should put to update the room" do
      FakeWeb.register_uri(:put, "http://mytoken:X@test.campfirenow.com/room/80749.json",
        :status => '200')
      @room.name = "Foo"
    end
  end
  
  describe "listen" do
    before do
      require 'twitter/json_stream'
      # Get EventMachine out of the way. We could be using em-spec, but seems like overkill for testing one method.
      module EventMachine; def self.run; yield end end
      @stream = mock(Twitter::JSONStream)
      @stream.stub!(:each_item)
    end
    
    it "should get from the streaming url" do
      Twitter::JSONStream.should_receive(:connect).
        with({:host=>"streaming.campfirenow.com", :path=>"/room/80749/live.json", :auth=>"mytoken:X", :timeout=>2}).
        and_return(@stream)
      @room.listen { }
    end
    
    it "should raise an exception if no block is given" do
      lambda {
        @room.listen
      }.should raise_error("no block provided")
    end
  end
end
