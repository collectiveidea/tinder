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
  
  def test_prepare_request_returns_request
    request = Net::HTTP::Get.new("does_not_matter")
    assert_equal request, @campfire.send(:prepare_request, request)
  end
  
  def test_prepare_request_sets_cookie
    request = Net::HTTP::Get.new("does_not_matter")
    @campfire.instance_variable_set("@cookie", "foobar")
    assert_equal "foobar", @campfire.send(:prepare_request, request)['Cookie']
  end
  
  def test_perform_request
    response = mock("response")
    Net::HTTP.any_instance.stubs(:request).returns(response)
    request = Net::HTTP::Get.new("does_not_matter")
    response.expects(:[]).with('set-cookie')
    
    assert_equal response, @campfire.send(:perform_request) { request }
  end
end