require 'rubygems'
require 'ruil'
require 'rspec'

describe "Ruil::Request" do

  before(:all) do
    @rack_request = Rack::Request.new({})
    @ruil_request = Ruil::Request.new(@rack_request)
  end

  it 'should contain the rack request' do
    @ruil_request.rack_request.should == @rack_request
  end

  it 'should allow access to generated data' do
    @ruil_request.generated_data.should == {}
    @ruil_request.generated_data[:x] = "y"
    @ruil_request.generated_data.should == {:x => "y"}
  end

  it 'should get the default html mode' do
    @ruil_request.html_mode.should == :desktop
  end

end
