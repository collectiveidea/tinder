require File.dirname(__FILE__) + '/../test_helper'

class CampfireTest < Test::Unit::TestCase
  
  def setup
    @campfire = Campfire.new 'opensoul'
    @campfire.login 'brandon@opensoul.org', 'ca3dm0n'
  end
  
  def test_create_and_delete_room
    room = @campfire.create_room('Testing123')
    
    assert room.is_a?(Campfire::Room), "expected a Campfire::Room but was a #{room.class}"
    assert_equal "61318", room.id
    
    room.destroy
    assert_nil @campfire.find_room_by_name('Testing123')
  end
end