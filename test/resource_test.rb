require 'rubygems'
require 'ruil/resource'

describe Ruil::Resource do

  before(:all) do
    user_agent_parser = Proc.new do |env|
      /Mobile/ === env['HTTP_USER_AGENT'] ? :mobile : :desktop
    end
    class TestResource < Ruil::Resource
      def options
        super.merge({ :x => 1 })
      end
    end
    @resource = TestResource.new(
      :user_agent_parser => user_agent_parser,
      :path_pattern = /\/test/
    ) do |r|
      Dir["test/resource_templates/test.*.tenjin.html"].each do |t|
        r << Ruil::Tenjin.new(t)
      end
    end
  end

  it 'should display a content' do
    env = { 'HTTP_USER_AGENT' => 'Mobile'}
    @resource.call(env).should == [200, {"Content-Type" => "text/html"}, ['mobile 1']]
    env = { 'HTTP_USER_AGENT' => 'Desktop' }
    @resource.call(env).should == [200, {"Content-Type" => "text/html"}, ['desktop 1']]
  end

  it 'could check if it matches an URL' do
    (@resource === { 'PATH_INFO' => '/test/1234' }).should == true
    (@resource === { 'PATH_INFO' => '/other/1234' }).should == false
  end

end
