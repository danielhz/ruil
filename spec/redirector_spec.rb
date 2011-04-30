require 'rubygems'
require 'ruil'
require 'rspec'

describe Ruil::Redirector do
  before(:all) do
    @url = '/unauthorized_url'
    rack_request = Rack::Request.new({})
    rack_request.path_info = @url
    ruil_request = Ruil::Request.new(rack_request)
    @response = Ruil::Redirector.new('/login').call(ruil_request)
  end

  it 'should get an redirection status' do
    @response.status.should == 302
  end

  it 'should get the url to be redirected' do
    @response.header['Location'].should == "/login?redirected_from=" + @url
  end

end
