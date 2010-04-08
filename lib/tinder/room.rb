module Tinder
  # A campfire room
  class Room
    attr_reader :id, :name

    def initialize(connection, attributes = {})
      @connection = connection
      @id = attributes['id']
      @name = attributes['name']
      @loaded = false
    end

    # Join the room. Pass +true+ to join even if you've already joined.
    def join(force = false)
      post 'join'
    end

    # Leave a room
    def leave
      post 'leave'
    end

    # Get the url for guest access
    def guest_url
      "#{@connection.uri}/#{guest_invite_code}" if guest_access_enabled?
    end

    def guest_access_enabled?
      load
      @open_to_guests ? true : false
    end

    # The invite code use for guest
    def guest_invite_code
      load
      @active_token_value
    end

    # Change the name of the room
    def name=(name)
      connection.put("/room/#{@id}.json", :body => {:room => {:name => name}}.to_json)
    end
    alias_method :rename, :name=

    # Change the topic
    def topic=(topic)
      connection.put("/room/#{@id}.json", :body => {:room => {:topic => topic}}.to_json)
    end

    # Get the current topic
    def topic
      load
      @topic
    end

    # Lock the room to prevent new users from entering and to disable logging
    def lock
      post :lock
    end

    # Unlock the room
    def unlock
      post :unlock
    end

    def ping(force = false)
      raise NotImplementedError
    end

    def destroy
      raise NotImplementedError
    end

    # Post a new message to the chat room
    def speak(message, options = {})
      send_message(message)
    end

    def paste(message)
      send_message(message, 'PasteMessage')
    end

    def play(sound)
      send_message(sound, 'SoundMessage')
    end

    # Get the list of users currently chatting for this room
    def users
      reload!
      @users
    end

    # return the user with the given id; if it isn't in our room cache, do a request to get it
    def user(id)
      if id
        user = users.detect {|u| u[:id] == id }
        unless user
          user_data = connection.get("/users/#{id}.json")
          user = user_data && user_data[:user]
        end
        user[:created_at] = Time.parse(user[:created_at])        
        user
      end
    end
    
    # Listen for new messages in the room, yielding them to the provided block as they arrive.
    # Each message is a hash with:
    # * +:body+: the body of the message
    # * +:user+: Campfire user, which is itself a hash, of:
    #   * +:id+: User id
    #   * +:name+: User name
    #   * +:email_address+: Email address
    #   * +:admin+: Boolean admin flag
    #   * +:created_at+: User creation timestamp
    #   * +:type+: User type (e.g. Member)
    # * +:id+: Campfire message id
    # * +:type+: Campfire message type
    # * +:room_id+: Campfire room id
    # * +:created_at+: Message creation timestamp
    #
    #   room.listen do |m|
    #     room.speak "Go away!" if m[:body] =~ /Java/i
    #   end
    def listen
      raise "no block provided" unless block_given?
      
      require 'twitter/json_stream'
      
      join # you have to be in the room to listen
      auth = connection.default_options[:basic_auth]
      options = {
        :host => "streaming.#{Connection::HOST}",
        :path => room_url_for(:live),
        :auth => "#{auth[:username]}:#{auth[:password]}",
        :timeout => 2
      }
      EventMachine::run do
        stream = Twitter::JSONStream.connect(options)
        stream.each_item do |message|
          message = HashWithIndifferentAccess.new(JSON.parse(message))
          message[:user] = user(message.delete(:user_id))
          message[:created_at] = Time.parse(message[:created_at])
          yield(message)
        end
      end
    end

    # Get the dates for the available transcripts for this room
    def available_transcripts
      raise NotImplementedError
    end

    # Get the transcript for the given date (Returns a hash in the same format as #listen)
    #
    #   room.transcript(room.available_transcripts.first)
    #   #=> [{:message=>"foobar!",
    #         :user_id=>"99999",
    #         :person=>"Brandon",
    #         :id=>"18659245",
    #         :timestamp=>=>Tue May 05 07:15:00 -0700 2009}]
    #
    # The timestamp slot will typically have a granularity of five minutes.
    #
    def transcript(transcript_date)
      url = "/room/#{@id}/transcript/#{transcript_date.to_date.strftime('%Y/%m/%d')}.json"
      connection.get(url)['messages'].map do |room|
        { :id => room['id'],
          :user_id => room['user_id'],
          :message => room['body'],
          :timestamp => Time.parse(room['created_at']) }
      end
    end

    def upload(filename)
      File.open(filename, "rb") do |file|
        params = Multipart::MultipartPost.new('upload' => file)
        post(:uploads, :body => params.query)
      end
    end

    # Get the list of latest files for this room
    def files(count = 5)
      get(:uploads)['uploads'].map { |u| u['full_url'] }
    end

    protected
      def load
        reload! unless @loaded
      end

      def reload!
        attributes = connection.get("/room/#{@id}.json")['room']

        @id = attributes['id']
        @name = attributes['name']
        @topic = attributes['topic']
        @full = attributes['full']
        @open_to_guests = attributes['open_to_guests']
        @active_token_value = attributes['active_token_value']
        @users = attributes['users']

        @loaded = true
      end

      def send_message(message, type = 'TextMessage')
        post 'speak', :body => {:message => {:body => message, :type => type}}.to_json
      end

      def get(action, options = {})
        connection.get(room_url_for(action), options)
      end

      def post(action, options = {})
        connection.post(room_url_for(action), options)
      end

      def room_url_for(action)
        "/room/#{@id}/#{action}.json"
      end

      def connection
        @connection
      end
  end
end
