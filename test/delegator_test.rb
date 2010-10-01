require 'rubygems'
require 'ruil/delegator'
require 'ruil/resource'
require 'ruil/tenjin_template'

describe 'Delegator' do

  before(:all) do
    a_resource = Class.new(Ruil::Resource) do
      def path_pattern
        /^\/a/
      end
      def template_pattern
        'a.*.html'
      end
    end
    b_resource = Class.new(Ruil::Resource) do
      def path_pattern
        /^\/b/
      end
      def template_pattern
        'b.*.html'
      end
    end
    user_agent_parser = Proc.new do |env|
      /Mobile/ === env['HTTP_USER_AGENT'] ? :mobile : :desktop
    end
    template_dir = File.join(File.dirname(__FILE__), 'templates')
    @delegator = Ruil::Delegator.new(:user_agent_parser => user_agent_parser,
                                     :template_dir => template_dir,
                                     :template_engine => Ruil::TenjinTemplate) do |d|
      d.add_resource a_resource
      d.add_resource b_resource
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
