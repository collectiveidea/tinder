# encoding: UTF-8
require 'spec_helper'

describe Tinder::Campfire do
  before do
    @campfire = Tinder::Campfire.new('test', :token => 'mytoken')
  end

  describe "rooms" do
    before do
      stub_connection(@campfire.connection) do |stub|
        stub.get('/rooms.json') {[200, {}, fixture('rooms.json')]}
      end
    end

    it "should return rooms" do
      @campfire.rooms.size.should be == 2
      @campfire.rooms.first.should be_kind_of(Tinder::Room)
    end

    it "should set the room name and id" do
      room = @campfire.rooms.first
      room.name.should be == 'Room 1'
      room.id.should be == 80749
    end
  end

  describe "find_by_id" do
    before do
      stub_connection(@campfire.connection) do |stub|
        stub.get('/rooms.json') {[200, {}, fixture('rooms.json')]}
      end
    end

    it "should return a Tinder::Room object when a match is found" do
      room = @campfire.find_room_by_id 80749
      room.should be_kind_of(Tinder::Room)
    end

    it "should return nil when no match is found" do
      room = @campfire.find_room_by_id 123
      room.should be nil
    end
  end

  describe "find_room_by_name" do
    before do
      stub_connection(@campfire.connection) do |stub|
        stub.get('/rooms.json') {[200, {}, fixture('rooms.json')]}
      end
    end

    it "should return a Tinder::Room object when a match is found" do
      room = @campfire.find_room_by_name 'Room 1'
      room.should be_kind_of(Tinder::Room)
    end

    it "should return nil when no match is found" do
      room = @campfire.find_room_by_name 'asdf'
      room.should be nil
    end
  end

  describe "users" do
    before do
      stub_connection(@campfire.connection) do |stub|
        stub.get('/rooms.json') {[200, {}, fixture('rooms.json')]}

        [80749, 80751].each do |id|
          stub.get("/room/#{id}.json") {[200, {}, fixture("rooms/room#{id}.json")]}
        end
      end
    end

    it "should return a sorted list of users in all rooms" do
      @campfire.users.length.should be == 2
      @campfire.users.first[:name].should be == "Jane Doe"
      @campfire.users.last[:name].should be == "John Doe"
    end
  end

  describe "me" do
    before do
      stub_connection(@campfire.connection) do |stub|
        stub.get("/users/me.json") {[200, {}, fixture('users/me.json')]}
      end
    end

    it "should return the current user's information" do
      @campfire.me["name"].should be == "John Doe"
    end
  end
end
