require File.dirname(__FILE__) + '/../test_helper'

class RemoteCampfireTest < Test::Unit::TestCase
  
  def setup
    @campfire = Tinder::Campfire.new 'opensoul'
    @user, @pass = 'brandon@opensoul.org', 'testing'
  end
  
  def test_create_and_delete_room
    assert login
    room = @campfire.create_room('Testing123')
    
    assert Tinder::Room, room
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

  def login(user = @user, pass = @pass)
    @campfire.login(user, pass)
  end
  
end