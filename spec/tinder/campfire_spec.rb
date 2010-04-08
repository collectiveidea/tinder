require 'spec_helper'

describe Tinder::Campfire do
  before do
    @campfire = Tinder::Campfire.new('test', :token => 'mytoken')
  end
  
  describe "rooms" do
    before do
      FakeWeb.register_uri(:get, "http://mytoken:X@test.campfirenow.com/rooms.json",
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
  
  describe "users" do
    before do
      FakeWeb.register_uri(:get, "http://mytoken:X@test.campfirenow.com/rooms.json",
        :body => fixture('rooms.json'), :content_type => "application/json")
      [80749, 80751].each do |id|
        FakeWeb.register_uri(:get, "http://mytoken:X@test.campfirenow.com/room/#{id}.json",
        :body => fixture("rooms/room#{id}.json"), :content_type => "application/json")
      end
    end
    
    it "should return a sorted list of users in all rooms" do
      @campfire.users.length.should == 2
      @campfire.users.first[:name].should == "Jane Doe"
      @campfire.users.last[:name].should == "John Doe"
    end
  end
  
  describe "me" do
    before do
      FakeWeb.register_uri(:get, "http://mytoken:X@test.campfirenow.com/users/me.json",
        :body => fixture('users/me.json'), :content_type => "application/json")
    end
    
    it "should return the current user's information" do
      @campfire.me["name"].should == "John Doe"
    end
  end
end
