require 'rubygems'

describe Ruil::Template, 'when first created' do

  before(:all) do
    # Initialize a Ruil::Template using a file name.
  end

  it 'should parse the name parameter' do
    # TODO
  end

  it 'should parse the key parameter' do
    # TODO
  end

  it 'should parse the engine parameter' do
    # TODO
  end

  it 'should parse the media type' do
    # TODO
  end

end


describe Ruil::Template, 'when rendering' do

  before(:all) do
    # Initialize a Ruil::Template using a file name.
  end

  it 'should display some random data' do
    data = { :r => (1...10).map { |x| rand } }
    # TODO
  end

end
