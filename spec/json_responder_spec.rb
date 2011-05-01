require 'rubygems'
require 'ruil'
require 'json'
require 'rspec'

describe Ruil::JSONResponder do

  before(:all) do
    request = Ruil::Request.new(Rack::Request.new({'PATH_INFO' => 'foo.js'}))
    @data = { :r => (1...10).map { |x| rand } }
    request.generated_data = @data
    @response = Ruil::JSONResponder.instance.call(request)
  end

  it 'should get an OK status' do
    @response.status.should == 200
  end

  it 'should get the JSON media type' do
    @response.header['Content-Type'].should == 'application/json'
  end

  it 'should render json files' do
    rendered = JSON.parse(@response.body.join)
    rendered['r'].each_index do |i|
      rendered['r'][i].to_s.should == @data[:r][i].to_s
    end
  end

end
