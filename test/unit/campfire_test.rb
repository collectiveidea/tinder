require File.dirname(__FILE__) + '/../test_helper'

class CampfireTest < Test::Unit::TestCase
  
  def setup
    @campfire = Tinder::Campfire.new("foobar")
    @response = mock("response")
  end
  
  def test_verify_response_redirect_true
    @response.expects(:code).returns(302)
    assert true === @campfire.send(:verify_response, @response, :redirect)
  end
  
  def test_verify_response_redirect_false
    @response.expects(:code).returns(200)
    assert false === @campfire.send(:verify_response, @response, :redirect)
  end
    
  def test_verify_response_success
    @response.expects(:code).returns(200)
    assert true === @campfire.send(:verify_response, @response, :success)
  end

  def test_verify_response_redirect_to
    @response.expects(:code).returns(304)
    @response.expects(:[]).with('location').returns("/foobar")
    assert true === @campfire.send(:verify_response, @response, :redirect_to => '/foobar')
  end
  
  def test_verify_response_redirect_to_without_redirect
    @response.expects(:code).returns(200)
    assert false === @campfire.send(:verify_response, @response, :redirect_to => '/foobar')
  end
  
  def test_verify_response_redirect_to_wrong_path
    @response.expects(:code).returns(302)
    @response.expects(:[]).with('location').returns("/baz")
    assert false === @campfire.send(:verify_response, @response, :redirect_to => '/foobar')
  end
  
  
end