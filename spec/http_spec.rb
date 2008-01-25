require File.dirname(__FILE__) + '/spec_helper'

describe Net::HTTPRequest, 'to_s' do
  
  before do
    @req = Net::HTTP::Get.new('/resource')
    @req.body = 'body'
  end
  
  it "should be the raw HTTP request" do
    @req.to_s.should == "GET /resource HTTP/1.1\r\nAccept: */*\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: 4\r\n\r\nbody"
  end
end

describe Net::HTTPResponse, "to_s" do
  RESPONSE = <<-EOF
HTTP/1.x 200 OK
Cache-Control: private
Content-Type: text/html; charset=UTF-8
Content-Length: 13
Date: Tue, 15 Jan 2008 14:50:22 GMT

Response body
EOF

  before do
    io = StringIO.new(RESPONSE)
    @response = Net::HTTPResponse.read_new(io)
    @response.reading_body(io, true)
  end
  
  it "should show the raw response" do
    @response.to_s.should == RESPONSE
  end
end