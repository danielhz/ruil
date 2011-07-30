require 'rubygems'
require 'ruil'
require 'rspec'

describe Ruil::Register do

  before(:all) do
    class MockResponse
      def initialize(value)
        @value = value
      end
      def finish
        @value
      end
    end
    class MockResource
      def initialize(value)
        @value = value
      end
      def call(request)
        request.path_info == @value ? MockResponse.new(@value).finish : false
      end
      def request_methods
        ['GET']
      end
    end
    (0..9).each do |value|
      Ruil::Register << MockResource.new(value.to_s)
    end
  end

  it 'should get responses for requests' do
    (1..10).each do
      value = rand(10).to_s
      request = Rack::Request.new({
        'REQUEST_METHOD' => 'GET',
        'PATH_INFO'      => value
      })
      Ruil::Register.call(request).should == value
    end
  end

end
