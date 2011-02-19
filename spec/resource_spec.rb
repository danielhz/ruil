require 'rubygems'
require 'ruil/resource'
require 'ruil/template'
require 'ruil/path_info_parser'
require 'ruil/register'
require 'rspec'

describe Ruil::Resource do

  before(:all) do
    @resource = Ruil::Resource.new(:get, '/test/:id') do |r|
      r.content_generator = Proc.new{ |e| e[:path_info_params] }
    end
  end

  it 'should response to a request' do
    env = { 'HTTP_USER_AGENT' => 'Mobile'}.merge({'PATH_INFO' => '/test/12.json'})
    @resource.call(env).should == [200, {"Content-Type" => "application/json"}, ['{"id":"12"}']]
    env = { 'HTTP_USER_AGENT' => 'Mobile'}.merge({'PATH_INFO' => '/test/12/aaa'})
    @resource.call(env).should == false
  end

end
