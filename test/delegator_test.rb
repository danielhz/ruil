require 'rubygems'
require 'ruil/delegator'
require 'ruil/resource'
require 'ruil/tenjin_template'

describe 'Delegator' do

  before(:all) do
    user_agent_parser = Proc.new do |env|
      /Mobile/ === env['HTTP_USER_AGENT'] ? :mobile : :desktop
    end
    @delegator = Delegator.new do |d|
      d << Ruil::Resource.new (
        :user_agent_parser => user_agent_parser,
        :path_pattern => /\/a./
      ) do |r|
        Dir["test/resource_templates/a.*.tenjin.html"].each do |t|
          r << Ruil::TenjinTemplate.new(t)
        end
      end
      d << Ruil::Resource.new (
        :user_agent_parser => user_agent_parser,
        :path_pattern => /\/b./
      ) do |r|
        Dir["test/resource_templates/b.*.tenjin.html"].each do |t|
          r << Ruil::TenjinTemplate.new(t)
        end
      end
    end
  end

  it 'delegate a request' do
    env = { 'PATH_INFO' => '/a', 'HTTP_USER_AGENT' => 'Mobile' }
    exp = [200, {"Content-Type" => "text/html"}, ["a mobile\n"]]
    @delegator.call(env).should == exp
    env = { 'PATH_INFO' => '/a', 'HTTP_USER_AGENT' => 'Desktop' }
    exp = [200, {"Content-Type" => "text/html"}, ["a desktop\n"]]
    @delegator.call(env).should == exp
    env = { 'PATH_INFO' => '/b', 'HTTP_USER_AGENT' => 'Desktop' }
    exp = [200, {"Content-Type" => "text/html"}, ["b desktop\n"]]
    @delegator.call(env).should == exp
    env = { 'PATH_INFO' => '/c', 'HTTP_USER_AGENT' => 'Desktop' }
    exp =[ 302, {"Content-Type" => "text/html", 'Location'=> '/' }, [] ]
    @delegator.call(env).should == exp
  end

end
