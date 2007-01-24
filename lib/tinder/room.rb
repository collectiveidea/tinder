module Tinder
  class Room
    attr_accessor :id, :name

    def initialize(campfire, id, name = nil)
      @campfire = campfire
      self.id = id
      self.name = name
    end

    def toggle_guest_access
      verify_response(post("room/#{self.id}/toggle_guest_access"), :success)
    end

    def guest_url
      (Hpricot(@campfire.send(:get, "room/#{self.id}").body)/"#guest_access h4").first.inner_html
    end

    def guest_invite_code
      guest_url.scan(/^http:\/\/#{@campfire.host}\/(\w*)$/).to_s
    end

    def rename(name)
      name if verify_response(post("account/edit/room/#{self.id}", { :room => { :name => name }}, :ajax => true), :success)
    end

    def change_topic(topic)
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
      message if verify_response(post("room/#{self.id}/speak", { :message => message, }.merge(options), :ajax => true), :success)
    end

  end
end