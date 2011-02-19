require 'rubygems'
require 'ruil/json_template'
require 'json'
require 'rspec'

describe Ruil::JSONTemplate do
  before(:all) do
    @template = Ruil::JSONTemplate.instance
  end

  it 'should have a JSON mime type' do
    @template.media_type.should == 'application/json'
  end

  it 'should answer to a "json" key' do
    @template.key.should == :json
  end

  it 'should render json files' do
    data = { :r => (1...10).map { |x| rand } }
    rendered = JSON.parse(@template.call(data))
    rendered['r'].each_index do |i|
      rendered['r'][i].to_s.should == data[:r][i].to_s
    end
  end
end
