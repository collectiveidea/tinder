# encoding: UTF-8
module Tinder

  # == Usage
  #
  #   campfire = Tinder::Campfire.new 'mysubdomain', :token => 'xyz'
  #
  #   room = campfire.create_room 'New Room', 'My new campfire room to test tinder'
  #   room.speak 'Hello world!'
  #   room.destroy
  #
  #   room = campfire.find_room_by_guest_hash 'abc123', 'John Doe'
  #   room.speak 'Hello world!'
  class Campfire
    attr_reader :connection

    # Create a new connection to the campfire account with the given +subdomain+.
    #
    # == Options:
    # * +:ssl+: use SSL for the connection, which is required if you have a Campfire SSL account.
    #           Defaults to true
    # * +:ssl_options+: SSL options passed to the underlaying Faraday connection. Allows to specify if the SSL certificate should be verified (:verify => true|false) and to specify the path to the ssl certs directory (:ca_path => "path/certs")
    #           Defaults to {:verify => true}
    # * +:proxy+: a proxy URI. (e.g. :proxy => 'http://user:pass@example.com:8000')
    #
    #   c = Tinder::Campfire.new("mysubdomain", :ssl => true)
    def initialize(subdomain, options = {})
      @connection = Connection.new(subdomain, options)
    end

    # Get an array of all the available rooms
    # TODO: detect rooms that are full (no link)
    def rooms
      connection.get('/rooms.json')['rooms'].map do |room|
        Room.new(connection, room)
      end
    end

    # Find a campfire room by id
    # NOTE: id should be of type Integer
    def find_room_by_id(id)
      id = id.to_i
      rooms.detect { |room| room.id == id }
    end

    # Find a campfire room by name
    def find_room_by_name(name)
      rooms.detect { |room| room.name == name }
    end

    # Find a campfire room by its guest hash
    def find_room_by_guest_hash(hash, name)
      rooms.detect { |room| room.guest_invite_code == hash }
    end

    # Creates and returns a new Room with the given +name+ and optionally a +topic+
    def create_room(name, topic = nil)
      connection.post('/rooms.json', { :room => { :name => name, :topic => topic } })
      find_room_by_name(name)
    end

    def find_or_create_room_by_name(name)
      find_room_by_name(name) || create_room(name)
    end

    # List the users that are currently chatting in any room
    def users
      rooms.map(&:users).flatten.compact.uniq.sort_by {|u| u[:name]}
    end

    # get the user info of the current user
    def me
      connection.get("/users/me.json")["user"]
    end
  end
end
