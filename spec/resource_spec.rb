require 'rubygems'
require 'ruil'
require 'rspec'

describe Ruil::Resource do

  before(:all) do
    @resource = Ruil::Resource.new('GET', '/test/:id') do |request|
      request.generated_data = request.generated_data[:path_info_params]
    end
  end

  it 'should get responses for requests' do
    request = Rack::Request.new({
      'REQUEST_METHOD'  => 'GET',
      'HTTP_USER_AGENT' => 'Mobile',
      'PATH_INFO'       => '/test/12.js'
    })
    response = @resource.call(request)
    response.status.should == 200
    response.headers["Content-Type"].should == "application/json"
    response.body.should == ['{"id":"12"}']
    request = Rack::Request.new({
      'REQUEST_METHOD'  => 'GET',
      'HTTP_USER_AGENT' => 'Mobile',
      'PATH_INFO'       => '/test/12/aaa'
    })
    @resource.call(request).should == false
  end

end
