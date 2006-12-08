#require File.dirname(__FILE__) + '/test_helper'
require 'test/unit'
require 'rubygems'
require 'active_support'
require File.dirname(__FILE__) + '/../lib/campfire.rb'

class CampfireTest < Test::Unit::TestCase
  
  def setup
    @campfire = Campfire.new 'opensoul'
    @user, @pass = 'brandon@opensoul.org', 'testing'
  end
  
  def test_create_and_delete_room
    assert login
    room = @campfire.create_room('Testing123')
    
    assert room.is_a?(Campfire::Room), "expected a Campfire::Room but was a #{room.class}"
    assert_not_nil room.id
    assert_equal "new name", room.rename("new name")
    
    room.destroy
    assert_nil @campfire.find_room_by_name('Testing123')
  end
  
  def test_failed_login
    assert !@campfire.login(@user, 'notmypassword')
  end
  
  def test_find_nonexistent_room
    login
    assert_nil @campfire.find_room_by_name('No Room Should Have This Name')
  end

private

  def login
    @campfire.login('brandon@opensoul.org', 'testing')
  end
  
end