require 'net/http'
require 'open-uri'
require 'hpricot'

class Campfire
  include Reloadable
  attr_accessor :subdomain, :host

  class Room
    include Reloadable
    attr_accessor :id
    
    def initialize(campfire, id)
      @campfire = campfire
      self.id = id
    end
    
    def toggle_guest_access
      @campfire.send :post, "room/#{self.id}/toggle_guest_access"
    end
    
    def guest_url
      (Hpricot(@campfire.send(:get, "room/#{self.id}").body)/"#guest_access h4").first.inner_html
    end
    
    def guest_invite_code
      guest_url.scan(/^#{@campfire.url}\/(\w*)$/).to_s
    end
    
    def destroy
      @campfire.send :post, "account/delete/room/#{self.id}"
    end
    
    def speak(message)
      @campfire.send :post, "room/#{self.id}/speak", { :message => message }, :ajax => true
    end
    
  end
  
  def initialize(subdomain)
    self.subdomain = subdomain
    self.host = "#{subdomain}.campfirenow.com"
  end
  
  def login(email, password)
    post("login", :email_address => email, :password => password)
  end
  
  def create_room(name, description = nil)
    post("account/create/room?from=lobby", {:room => {:name => name, :descripton => description}}, :ajax => true)
    find_room_by_name(name)
  end
  
  def find_room_by_name(name)
    link = Hpricot(get.body).search("//h2/a").detect { |a| a.inner_html == name }
    link.blank? ? nil : Room.new(self, link.attributes['href'].scan(/room\/(\d*)$/).to_s)
  end

private

  def post(path, data = {}, options = {})
    request = returning Net::HTTP::Post.new("http://#{host}/#{path}") do |request|
      prepare_request(request, options)
      request.add_field 'Content-Type', 'application/x-www-form-urlencoded'
      request.set_form_data data.stringify_keys
    end
    returning Net::HTTP.new(host, 80).start { |http| http.request(request) } do |response|
      @cookie = response['set-cookie'] if response['set-cookie']
    end
  end
  
  def get(path = nil, options = {})
    request = returning Net::HTTP::Get.new("http://#{host}/#{path}") do |request|
      prepare_request(request, options)
    end
    returning Net::HTTP.new(host, 80).start { |http| http.request(request) } do |response|
      @cookie = response['set-cookie'] if response['set-cookie']
    end
  end
  
  def prepare_request(request, options = {})
    request.add_field 'Cookie', @cookie if @cookie
    if options[:ajax]
      request.add_field 'X-Requested-With', 'XMLHttpRequest'
      request.add_field 'X-Prototype-Version', '1.5.0_rc1'
    end
  end
  
end