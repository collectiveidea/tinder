module Tinder
  class Room
    attr_accessor :id, :name

    def initialize(campfire, id, name = nil)
      @campfire = campfire
      self.id = id
      self.name = name
      @room = get("room/#{self.id}")
      @membership_key = @room.body.scan(/\"membershipKey\": \"([a-z0-9]+)\"/).to_s
      @user_id = @room.body.scan(/\"userID\": (\d+)/).to_s
      @last_cache_id = @room.body.scan(/\"lastCacheID\": (\d+)/).to_s
      @timestamp = @room.body.scan(/\"timestamp\": (\d+)/).to_s
    end
    
    def leave
      verify_response get("/room/#{@room_id}/leave"), :redirect
    end

    def toggle_guest_access
      verify_response(post("room/#{self.id}/toggle_guest_access"), :success)
    end

    def guest_url
      (Hpricot(get("room/#{self.id}").body)/"#guest_access h4").first.inner_html
    end

    def guest_invite_code
      guest_url.scan(/^http:\/\/#{@campfire.host}\/(\w*)$/).to_s
    end

    def rename(name)
      name if verify_response(post("account/edit/room/#{self.id}", { :room => { :name => name }}, :ajax => true), :success)
    end

    def topic=(topic)
      topic if verify_response(post("room/#{self.id}/change_topic", { 'room' => { 'topic' => topic }}, :ajax => true), :success)
    end

    def lock
      verify_response(post("room/#{self.id}/lock", {}, :ajax => true), :success)
    end

    def unlock
      verify_response(post("room/#{self.id}/unlock", {}, :ajax => true), :success)
    end

    def destroy
      verify_response(post("account/delete/room/#{self.id}"), :success)
    end

    def speak(message)
      send message
    end

    def paste(message)
      send message, { :paste => true }
    end

    def users
       @campfire.users self.name
    end
    
    def listen
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
          messages
        end
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
      message if verify_response(post("room/#{self.id}/speak", { :message => message, :t => Time.now.to_i }.merge(options), :ajax => true), :success)
    end

  end
end