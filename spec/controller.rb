require 'rubygems'
require 'ruil'
require 'rspec'

describe Ruil::Register do

  before(:all) do
    class TestController
      extend Ruil::Controller

      resource 'GET', '/' do |request|
        ok :text, 'Hola'
      end
    end
  end

  it 'should get responses for requests' do
    request = Rack::Request.new(
      Rack::MockRequest::DEFAULT_ENV.merge({
        'REQUEST_METHOD'  => 'GET',
        'HTTP_USER_AGENT' => 'Mobile',
        'PATH_INFO'       => '/'
    }))
    Ruil::Register.call(request)
  end

end

