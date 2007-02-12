module Tinder
  class Room
    attr_reader :id, :name

    def initialize(campfire, id, name = nil)
      @campfire = campfire
      @id = id
      @name = name
    end
    
    def join(force = false)
      @room = returning(get("room/#{id}")) do |room|
        return false unless verify_response(room, :success)
        @membership_key = room.body.scan(/\"membershipKey\": \"([a-z0-9]+)\"/).to_s
        @user_id = room.body.scan(/\"userID\": (\d+)/).to_s
        @last_cache_id = room.body.scan(/\"lastCacheID\": (\d+)/).to_s
        @timestamp = room.body.scan(/\"timestamp\": (\d+)/).to_s
      end unless @room || force
      block_given? ? yield : true
    end
    
    def leave
      returning verify_response(get("room/#{id}/leave"), :redirect) do
        @room, @membership_key, @user_id, @last_cache_id, @timestamp = nil
      end
    end

    def toggle_guest_access
      verify_response(post("room/#{id}/toggle_guest_access"), :success)
    end

    def guest_url
      join { (Hpricot(@room.body)/"#guest_access h4").first.inner_html }
    end

    def guest_invite_code
      guest_url.scan(/\/(\w*)$/).to_s
    end

    def name=(name)
      @name = name if verify_response(post("account/edit/room/#{id}", { :room => { :name => name }}, :ajax => true), :success)
    end
    alias_method :rename, :name=

    def topic=(topic)
      topic if verify_response(post("room/#{id}/change_topic", { 'room' => { 'topic' => topic }}, :ajax => true), :success)
    end

    def lock
      verify_response(post("room/#{id}/lock", {}, :ajax => true), :success)
    end

    def unlock
      verify_response(post("room/#{id}/unlock", {}, :ajax => true), :success)
    end

    def destroy
      verify_response(post("account/delete/room/#{id}"), :success)
    end

    def speak(message)
      join { send message }
    end

    def paste(message)
      join { send message, { :paste => true } }
    end

    def users
      @campfire.users name
    end
    
    def listen
      join do
        continue = true
        while(continue)
          messages = []
          response = post("poll.fcgi", :l => @last_cache_id, :m => @membership_key, :s => @timestamp, :t => "#{Time.now.to_i}000")
          if response.body.length > 1
            lines = response.body.split("\r\n")
            if lines.length > 0
              @last_cache_id = lines.pop.scan(/chat.poller.lastCacheID = (\d+)/).to_s
              lines.each do |msg|
                unless msg.match(/timestamp_message/)
                  messages << {
                    :id => msg.scan(/message_(\d+)/).to_s,
                    :user_id => msg.scan(/user_(\d+)/).to_s,
                    :person => msg.scan(/<span>(.+)<\/span>/).to_s,
                    :message => msg.scan(/<div>(.+)<\/div>/).to_s
                  }
                end
              end
            end
          end
          if block_given?
            messages.each do |msg|
              yield msg
            end
            sleep 5
          else
            continue = false
          end
        end
        messages
      end
    end
    

  private

    def post(*args)
      @campfire.send :post, *args
    end

    def get(*args)
      @campfire.send :get, *args
    end

    def verify_response(*args)
      @campfire.send :verify_response, *args
    end

    def send(message, options = {})
      message if verify_response(post("room/#{id}/speak", { :message => message, :t => Time.now.to_i }.merge(options), :ajax => true), :success)
    end

  end
end