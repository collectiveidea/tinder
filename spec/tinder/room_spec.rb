# encoding: UTF-8
require 'spec_helper'

describe Tinder::Room do
  before do
    @connection = Tinder::Connection.new('test', :token => 'mytoken')

    stub_connection(@connection) do |stub|
      stub.get('/room/80749.json') {[200, {}, fixture('rooms/show.json')]}
    end

    @room = Tinder::Room.new(@connection, 'id' => 80749, 'name' => 'Room 1')

    # Get EventMachine out of the way. We could be using em-spec, but seems like overkill
    require 'twitter/json_stream'
    module EventMachine; def self.run; yield end end
    EventMachine.stub!(:reactor_running?).and_return(true)
    @stream = mock(Twitter::JSONStream)
    @stream.stub!(:each_item)
    @stream.stub!(:on_error)
    @stream.stub!(:on_max_reconnects)
  end

  describe "join" do
    before do
      stub_connection(@connection) do |stub|
        stub.post('/room/80749/join.json') {[200, {}, ""]}
      end
    end

    it "should post to join url" do
      @room.join
    end
  end

  describe "leave" do
    before do
      stub_connection(@connection) do |stub|
        stub.post('/room/80749/leave.json') {[200, {}, ""]}
      end
    end

    it "should post to leave url" do
      @room.leave
    end

    it "stops listening" do
      @room.should_receive(:stop_listening)
      @room.leave
    end
  end

  describe "lock" do
    before do
      stub_connection(@connection) do |stub|
        stub.post('/room/80749/lock.json') {[200, {}, ""]}
      end
    end

    it "should post to lock url" do
      @room.lock
    end
  end

  describe "search" do
    before do
      stub_connection(@connection) do |stub|
        stub.get('/search/foo.json') {[200, {}, fixture("rooms/recent.json")]}
      end
    end

    it "should GET the search endpoint with the search term and filter by room" do
      @room.stub(:id).and_return(490096)
      @room.should_receive(:parse_message).exactly(2).times
      @room.search("foo")
    end

    it "should return empty array if no messages in room" do
      @room.should_receive(:parse_message).never
      @room.search("foo").should be_empty
    end
  end

  describe "transcript" do
    it "should GET the transcript endpoint with the provided date" do
      stub_connection(@connection) do |stub|
        stub.get('/room/80749/transcript/2012/10/15.json') {[200, {}, fixture("rooms/recent.json")]}
      end
      @room.should_receive(:parse_message).exactly(2).times
      @room.transcript(Date.parse('2012-10-15'))
    end

    it "should default to today's date" do
      stub_connection(@connection) do |stub|
        stub.get('/room/80749/transcript/1981/03/21.json') {[200, {}, fixture("rooms/recent.json")]}
      end
      Date.stub(:today).and_return(Date.parse('1981-03-21'))
      @room.should_receive(:parse_message).exactly(2).times
      @room.transcript
    end
  end

  describe "unlock" do
    before do
      stub_connection(@connection) do |stub|
        stub.post('/room/80749/unlock.json') {[200, {}, ""]}
      end
    end

    it "should post to unlock url" do
      @room.unlock
    end
  end

  describe "guest_url" do
    it "should use guest_invite_code if active" do
      @room.stub!(:guest_access_enabled? => true, :guest_invite_code => '123')
      @room.guest_url.should == "https://test.campfirenow.com/123"
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

  describe "topic" do
    it "should get the current topic" do
      @room.topic.should == "Testing"
    end

    it "should get the current topic even if it's changed" do
      @room.topic.should == "Testing"

      # reinitialize a new connection since we can't modify the
      # faraday stack after a request has already been submitted
      @connection = Tinder::Connection.new('test', :token => 'mytoken')

      # returning a different room's json to get a diff topic
      stub_connection(@connection) do |stub|
        stub.get('/room/80749.json') {[200, {}, fixture('rooms/room80751.json')]}
      end

      @room.topic.should == "Testing 2"

    end
  end


  describe "name=" do
    it "should put to update the room" do
      stub_connection(@connection) do |stub|
        stub.put('/room/80749.json') {[200, {}, ""]}
      end

      @room.name = "Foo"
    end
  end

  describe "listen" do
    before do
      stub_connection(@connection) do |stub|
        stub.post('/room/80749/join.json') {[200, {}, ""]}
      end
    end

    it "should get from the streaming url" do
      Twitter::JSONStream.should_receive(:connect).with(
        {
          :host=>"streaming.campfirenow.com",
          :path=>"/room/80749/live.json",
          :auth=>"mytoken:X",
          :timeout=>6,
          :ssl=>true
        }
      ).and_return(@stream)

      @room.listen { }
    end

    it "should raise an exception if no block is given" do
      lambda {
        @room.listen
      }.should raise_error(ArgumentError, "no block provided")
    end

    it "marks the room as listening" do
      Twitter::JSONStream.stub!(:connect).and_return(@stream)
      lambda {
        @room.listen { }
      }.should change(@room, :listening?).from(false).to(true)
    end
  end

  describe "stop_listening" do
    before do
      stub_connection(@connection) do |stub|
        stub.post('/room/80749/join.json') {[200, {}, ""]}
      end

      Twitter::JSONStream.stub!(:connect).and_return(@stream)
      @stream.stub!(:stop)
    end

    it "changes a listening room to a non-listening room" do
      @room.listen { }
      lambda {
        @room.stop_listening
      }.should change(@room, :listening?).from(true).to(false)
    end

    it "tells the json stream to stop" do
      @room.listen { }
      @stream.should_receive(:stop)
      @room.stop_listening
    end

    it "does nothing if the room is not listening" do
      @room.listen { }
      @room.stop_listening
      @room.stop_listening
    end
  end

  describe "recent" do
    before do
      stub_connection(@connection) do |stub|
        stub.get('/room/80749/recent.json') {[
          200, {}, fixture('rooms/recent.json')
        ]}
      end
    end

    it "should get a list of parsed recent messages" do
      @room.should_receive(:parse_message).exactly(2).times
      messages = @room.recent
    end
  end

  describe "parse_message" do
    it "expands user and parses created_at" do
      unparsed_message = {
        :user_id => 123,
        :body => 'An aunt is worth two nieces',
        :created_at => '2012/02/14 16:21:00 +0000'
      }
      expected = {
        :user => {
          :name => 'Dr. Noodles'
        },
        :body => 'An aunt is worth two nieces',
        :created_at => Time.parse('2012/02/14 16:21:00 +0000')
      }
      @room.stub(:user).with(123).and_return({ :name => 'Dr. Noodles' })

      actual = @room.parse_message(unparsed_message)
      actual.should == expected
    end
  end
end
