require 'spec_helper'

describe Tinder::Room do
  before do
    @campfire = Tinder::Campfire.new('test')
    @room = Tinder::Room.new(@campfire, 'id' => 80749)
  end
  
  describe "join" do
    FakeWeb.register_uri(:post, "http://test.campfirenow.com/room/80749/join.json", :status => '200')
    
    it "should post to join url" do
      @room.join
    end
  end

  describe "leave" do
    before do
      FakeWeb.register_uri(:post, "http://test.campfirenow.com/room/80749/leave.json", :status => '200')
    end
    
    it "should post to leave url" do
      @room.leave
    end
  end
  
  describe "lock" do
    before do
      FakeWeb.register_uri(:post, "http://test.campfirenow.com/room/80749/lock.json", :status => '200')
    end
    
    it "should post to lock url" do
      @room.lock
    end
  end
  
  describe "unlock" do
    before do
      FakeWeb.register_uri(:post, "http://test.campfirenow.com/room/80749/unlock.json", :status => '200')
    end
    
    it "should post to unlock url" do
      @room.unlock
    end
  end
  
end
