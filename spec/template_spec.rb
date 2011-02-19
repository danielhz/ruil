require 'rubygems'
require 'ruil/template'
require 'tenjin'
require 'rexml/document'
require 'rspec'

describe Ruil::Template do

  before(:all) do
    @template = Ruil::Template.new("spec/resource_templates/template_test.desktop.tenjin.html")
  end

  it 'should parse the key parameter' do
    @template.key.should == :desktop
  end

  it 'should parse the media type' do
    @template.media_type.should == 'text/html'
  end

  it 'should display some random data' do
    data = { :r => (1...10).map { |x| rand.to_s } }
    doc  = REXML::Document.new(@template.call(data))
    i = 0
    doc.elements.each("//ul/li") do |x|
      x.text.should == data[:r][i]
      i += 1
    end
  end

end
