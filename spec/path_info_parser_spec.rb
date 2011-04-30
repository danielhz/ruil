require 'rubygems'
require 'ruil'
require 'rspec'

describe "Ruil::PathInfoParser" do

  it 'should parse paths' do
    parser = Ruil::PathInfoParser.new('/foo/:type/:id')
    (parser === '/foo/bar/1').should    == {:type => 'bar', :id => '1'}
    (parser === '/foo/bar/3.js').should == {:type => 'bar', :id => '3'}
    (parser === '/foo').should          == false
    (parser === '/bar').should          == false
  end

end
