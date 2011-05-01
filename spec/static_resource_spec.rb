require 'rubygems'
require 'ruil'
require 'rspec'

describe Ruil::StaticResource do

  before(:all) do
    @resource = Ruil::StaticResource.new do |resource|
      Dir.mkdir '/tmp/spec'
      ['foo', 'bar'].each do |f|
        file_name = "/tmp/spec/#{f}.html"
        file = File.new(file_name, 'w')
        file << f
        file.close
        resource.add(file_name, "/#{f}.html", 'text/html')
      end
    end
  end

  after(:all) do
    Dir['/tmp/spec/*'].each { |f| File.delete f }
    Dir.delete '/tmp/spec'
  end

  it 'should respond files without layout' do
    ['foo', 'bar'].each do |f|
      request = Rack::Request.new({
        'REQUEST_METHOD' => 'GET',
        'PATH_INFO'      => "/#{f}.html"
      })
      response = @resource.call(request)
      response.status.should == 200
      response.body.should == ["#{f}"]
      response.header['Content-Type'].should == 'text/html'
    end
  end

end
