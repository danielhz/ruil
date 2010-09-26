require 'rubygems'
require 'ruil/resource'

describe 'Resource' do

  before(:all) do
    templates = {
      :mobile  => Proc.new { |opt| opt[:template_key].to_s },
      :desktop => Proc.new { |opt| opt[:template_key].to_s }
    }
    user_agent_parser = Proc.new do |env|
      /Mobile/ === env['HTTP_USER_AGENT'] ? :mobile : :desktop
    end
    @resource = Ruil::Resource.new(templates, user_agent_parser)
  end

  it 'should display a content' do
    env = { 'HTTP_USER_AGENT' => 'Mobile' }
    @resource.call(env).should == [200, {"Content-Type" => "text/html"}, ['mobile']]
    env = { 'HTTP_USER_AGENT' => 'Desktop' }
    @resource.call(env).should == [200, {"Content-Type" => "text/html"}, ['desktop']]
  end

end
