require 'spec_helper'

describe Tinder::Campfire do
  before do
    @campfire = Tinder::Campfire.new('test')
  end
  
  describe "authentication" do
    it "should raise an exception with bad credentials" do
      FakeWeb.register_uri(:get, "http://test.campfirenow.com/rooms.json",
        :body => "HTTP Basic: Access denied.", :status => ["401", "Unauthorized"])
      @campfire.rooms
    end
    
    it "should use basic auth for credentials" do
      FakeWeb.register_uri(:get, "http://user:password@test.campfirenow.com/rooms.json",
        :body => fixture('rooms.json'), :content_type => "application/json")
      @campfire.login 'user', 'password'
      @campfire.rooms
    end
  end
  
  describe "rooms" do
    before do
      FakeWeb.register_uri(:get, "http://test.campfirenow.com/rooms.json",
        :body => fixture('rooms.json'), :content_type => "application/json")
    end
    
    it "should return rooms" do
      @campfire.rooms.size.should == 2
      @campfire.rooms.first.should be_kind_of(Tinder::Room)
    end
    
    it "should set the room name and id" do
      room = @campfire.rooms.first
      room.name.should == 'Room 1'
      room.id.should == 80749
    end
  end
end
