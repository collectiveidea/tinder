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
      expect(@campfire.rooms.size).to eq(2)
      expect(@campfire.rooms.first).to be_kind_of(Tinder::Room)
    end

    it "should set the room name and id" do
      room = @campfire.rooms.first
      expect(room.name).to eq('Room 1')
      expect(room.id).to eq(80749)
    end
  end

  describe "presence" do
    before do
      stub_connection(@campfire.connection) do |stub|
        stub.get('/presence.json') {[200, {}, fixture('presence.json')]}
      end
    end

    it "should return rooms" do
      expect(@campfire.presence.size).to eq(3)
      expect(@campfire.presence.first).to be_kind_of(Tinder::Room)
    end

    it "should set the room name and id" do
      room = @campfire.presence.last
      expect(room.name).to eq('Room 3')
      expect(room.id).to eq(80754)
    end
  end

  describe "find_room_by_id" do
    before do
      stub_connection(@campfire.connection) do |stub|
        stub.get('/rooms.json') {[200, {}, fixture('rooms.json')]}
      end
    end

    it "should return a Tinder::Room object when a match is found" do
      room = @campfire.find_room_by_id 80749
      expect(room).to be_kind_of(Tinder::Room)
    end

    it "should return nil when no match is found" do
      room = @campfire.find_room_by_id 123
      expect(room).to eq(nil)
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
      expect(room).to be_kind_of(Tinder::Room)
    end

    it "should return nil when no match is found" do
      room = @campfire.find_room_by_name 'asdf'
      expect(room).to eq(nil)
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
      expect(@campfire.users.length).to eq(2)
      expect(@campfire.users.first[:name]).to eq("Jane Doe")
      expect(@campfire.users.last[:name]).to eq("John Doe")
    end
  end

  describe "me" do
    before do
      stub_connection(@campfire.connection) do |stub|
        stub.get("/users/me.json") {[200, {}, fixture('users/me.json')]}
      end
    end

    it "should return the current user's information" do
      expect(@campfire.me["name"]).to eq("John Doe")
    end
  end
end
