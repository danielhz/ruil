require 'rubygems'
require 'ruil'
require 'json'
require 'rspec'

describe Ruil::HTMLResponder do

  before(:all) do
    # Templates
    Dir.mkdir '/tmp/spec'
    ['html', 'xhtml'].each do |suffix|
      file = File.new("/tmp/spec/ruil.desktop.tenjin.#{suffix}", 'w')
      file << '<p id="' + suffix + '">#{@x}</p>'
      file.close
    end
    # Test a request
    @test_request = lambda do |responder, path_info, generated_data, content_type, layout|
      # Defining request
      request = Ruil::Request.new(Rack::Request.new({}))
      request.rack_request.path_info = path_info
      request.generated_data = {:x => generated_data}
      # Checking response
      response = responder.call(request)
      response.status.should == 200
      suffix = path_info.sub(/^.*\./, '')
      suffix = 'html' if suffix == path_info
      response.body.should == ["<p id=\"#{suffix}\">#{generated_data}</p>"]
      response.header['Content-Type'].should == content_type
    end
  end

  after(:all) do
    Dir['/tmp/spec/*'].each { |f| File.delete f }
    Dir.delete '/tmp/spec'
  end

  it 'should respond files without layout' do
    responder = Ruil::HTMLResponder.new('/tmp/spec/ruil')
    @test_request.call(responder, '/ruil.html', 'x', 'text/html', nil)
    @test_request.call(responder, '/ruil', 'x', 'text/html', nil)
    @test_request.call(responder, '/ruil.xhtml', 'x', 'application/xhtml+xml', nil)
  end

  it 'should respond using a html file with layout' do
    # TODO
  end

end
