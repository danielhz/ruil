require 'rubygems'
require 'ruil'
require 'rspec'

describe Ruil::Resource do

  before(:all) do
    @resource = Ruil::Resource.new('GET', '/test/:id') do |request|
      [200, {'Content-Type' => 'plain/text'}, [request.path_info]]
    end
  end

  it 'should get responses for requests' do
    request = Rack::Request.new(
      Rack::MockRequest::DEFAULT_ENV.merge({
        'REQUEST_METHOD'  => 'GET',
        'HTTP_USER_AGENT' => 'Mobile',
        'PATH_INFO'       => '/test/12'
    }))
    response = @resource.call(request)
    response[0].should == 200
    response[1]["Content-Type"].should == "plain/text"
    response[2].join.should == '/test/12'
    request = Rack::Request.new(
      Rack::MockRequest::DEFAULT_ENV.merge({
        'REQUEST_METHOD'  => 'GET',
        'HTTP_USER_AGENT' => 'Mobile',
        'PATH_INFO'       => '/test/12/aaa'
    }))
    @resource.call(request).should == false
  end

end
