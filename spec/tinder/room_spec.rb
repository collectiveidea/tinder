# encoding: UTF-8
require 'spec_helper'
require 'date'

describe Tinder::Room do

  def mock_listen_callbacks(stream)
    expect(stream).to receive(:each_item).with(any_args).and_return(true)
    expect(stream).to receive(:on_error)
    expect(stream).to receive(:on_max_reconnects)
  end

  before do
    @connection = Tinder::Connection.new('test', :token => 'mytoken')

    stub_connection(@connection) do |stub|
      stub.get('/room/80749.json') {[200, {}, fixture('rooms/show.json')]}
    end

    @room = Tinder::Room.new(@connection, 'id' => 80749, 'name' => 'Room 1')

    # Get EventMachine out of the way. We could be using em-spec, but seems like overkill
    require 'twitter/json_stream'
    module EventMachine; def self.run; yield end end
    expect(EventMachine).to receive(:reactor_running?).at_most(:once).and_return(true)

    @stream = double(Twitter::JSONStream)
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
      expect(@room).to receive(:stop_listening)
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
      expect(@room).to receive(:id).twice.and_return(490096)
      expect(@room).to receive(:parse_message).exactly(2).times
      @room.search("foo")
    end

    it "should return empty array if no messages in room" do
      expect(@room).not_to receive(:parse_message)
      expect(@room.search("foo")).to be_empty
    end
  end

  describe "transcript" do
    it "should GET the transcript endpoint with the provided date" do
      stub_connection(@connection) do |stub|
        stub.get('/room/80749/transcript/2012/10/15.json') {[200, {}, fixture("rooms/recent.json")]}
      end
      expect(@room).to receive(:parse_message).exactly(2).times
      @room.transcript(Date.parse('2012-10-15'))
    end

    it "should default to today's date" do
      stub_connection(@connection) do |stub|
        stub.get('/room/80749/transcript/1981/03/21.json') {[200, {}, fixture("rooms/recent.json")]}
      end
      expect(Date).to receive(:today).and_return(Date.parse('1981-03-21'))
      expect(@room).to receive(:parse_message).exactly(2).times
      @room.transcript
    end

    it "should return an array of messages" do
      stub_connection(@connection) do |stub|
        stub.get('/room/80749/transcript/2012/10/15.json') {[200, {}, fixture('rooms/recent.json')]}
        stub.get('/users/1158839.json') {[200, {}, fixture('users/me.json')]}
        stub.get('/users/1158837.json') {[200, {}, fixture('users/me.json')]}
      end

      expect(@room.transcript(Date.parse('2012-10-15'))).to be_a(Array)
    end

    it "should have messages with attributes" do
      stub_connection(@connection) do |stub|
        stub.get('/room/80749/transcript/2012/10/15.json') {[200, {}, fixture("rooms/recent.json")]}
        stub.get('/users/1158839.json') {[200, {}, fixture('users/me.json')]}
        stub.get('/users/1158837.json') {[200, {}, fixture('users/me.json')]}
      end

      message = @room.transcript(Date.parse('2012-10-15')).first

      expect(message[:id]).to be_a(Integer)
      expect(message[:user][:id]).to be_a(Integer)
      expect(message[:body]).to be_a(String)
      expect(message[:created_at]).to be_a(Time)
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
      expect(@room).to receive(:guest_access_enabled?).and_return(true)
      expect(@room).to receive(:guest_invite_code).and_return('123')
      expect(@room.guest_url).to eq("https://test.campfirenow.com/123")
    end

    it "should return nil when guest access is not enabled" do
      expect(@room).to receive(:guest_access_enabled?).and_return(false)
      expect(@room.guest_url).to be_nil
    end
  end

  it "should set guest_invite_code" do
    expect(@room.guest_invite_code).to eq("90cf7")
  end

  it "should set guest_access_enabled?" do
    expect(@room.guest_access_enabled?).to eq(true)
  end

  describe "topic" do
    it "should get the current topic" do
      expect(@room.topic).to eq("Testing")
    end

    it "should get the current topic even if it's changed" do
      expect(@room.topic).to eq("Testing")

      # reinitialize a new connection since we can't modify the
      # faraday stack after a request has already been submitted
      @connection = Tinder::Connection.new('test', :token => 'mytoken')

      # returning a different room's json to get a diff topic
      stub_connection(@connection) do |stub|
        stub.get('/room/80749.json') {[200, {}, fixture('rooms/room80751.json')]}
      end

      expect(@room.topic).to eq("Testing 2")

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
      expect(Twitter::JSONStream).to receive(:connect).with(
        {
          :host=>"streaming.campfirenow.com",
          :path=>"/room/80749/live.json",
          :auth=>"mytoken:X",
          :timeout=>6,
          :ssl=>true
        }
      ).and_return(@stream)
      mock_listen_callbacks(@stream)
      @room.listen { }
    end

    it "should raise an exception if no block is given" do
      expect {
        @room.listen
      }.to raise_error(ArgumentError, "no block provided")
    end

    it "marks the room as listening" do
      expect(Twitter::JSONStream).to receive(:connect).and_return(@stream)
      mock_listen_callbacks(@stream)
      expect {
        @room.listen { }
      }.to change(@room, :listening?).from(false).to(true)
    end
  end

  describe "stop_listening" do
    before do
      stub_connection(@connection) do |stub|
        stub.post('/room/80749/join.json') {[200, {}, ""]}
      end

      expect(Twitter::JSONStream).to receive(:connect).and_return(@stream)
      expect(@stream).to receive(:stop)
    end

    it "changes a listening room to a non-listening room" do
      mock_listen_callbacks(@stream)
      @room.listen { }
      expect {
        @room.stop_listening
      }.to change(@room, :listening?).from(true).to(false)
    end

    it "tells the json stream to stop" do
      mock_listen_callbacks(@stream)
      @room.listen { }
      @room.stop_listening
    end

    it "does nothing if the room is not listening" do
      mock_listen_callbacks(@stream)
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
      expect(@room).to receive(:parse_message).exactly(2).times
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
      expect(@room).to receive(:user).with(123).and_return({ :name => 'Dr. Noodles' })

      actual = @room.parse_message(unparsed_message)
      expect(actual).to eq(expected)
    end
  end

  describe "user" do
    before do
      expect(@room).to receive(:current_users).and_return([
        { :id => 1, :name => 'The Amazing Crayon Executive'},
        { :id => 2, :name => 'Lord Pants'},
      ])
      @not_current_user = { :id => 3, :name => 'Patriot Sally'}
    end

    it "looks up user if not already in room's cache" do
      expect(@room).to receive(:fetch_user).with(3).
        and_return(@not_current_user)
      expect(@room.user(3)).to eq(@not_current_user)
    end

    it "pulls user from room's cache if user in participant list" do
      expect(@room).not_to receive(:fetch_user)
      user = @room.user(1)
    end

    it "adds user to cache after first lookup" do
      expect(@room).to receive(:fetch_user).with(3).at_most(:once).
        and_return(@not_current_user)
      expect(@room.user(3)).to eq(@not_current_user)
      expect(@room.user(3)).to eq(@not_current_user)
    end
  end

  describe "fetch_user" do
    before do
      stub_connection(@connection) do |stub|
        stub.get("/users/5.json") {[200, {}, fixture('users/me.json')]}
      end
    end

    it "requests via GET and returns the requested user's information" do
      expect(@room.fetch_user(5)['name']).to eq('John Doe')
    end
  end

  describe "current_users" do
    it "returns list of currently participating users" do
      current_users = @room.current_users
      expect(current_users.size).to eq(1)
      expect(current_users.first[:name]).to eq('Brandon Keepers')
    end
  end

  describe "users" do
    it "returns current users if cache has not been initialized yet" do
      expect(@room).to receive(:current_users).and_return(:the_whole_spittoon)
      expect(@room.users).to eq(:the_whole_spittoon)
    end

    it "returns current users plus any added cached users" do
      expect(@room).to receive(:current_users).and_return([:mia_cuttlefish])
      @room.users << :guy_wearing_new_mexico_as_a_hat
      expect(@room.users).to eq([:mia_cuttlefish, :guy_wearing_new_mexico_as_a_hat])
    end
  end
end
