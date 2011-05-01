require 'rubygems'
require 'ruil'
require 'json'
require 'rspec'

describe Ruil::HTMLResponder do

  before(:all) do
    # Define templates and requests
    Dir.mkdir '/tmp/spec'
    @templates = []
    request = Ruil::Request.new(Rack::Request.new({}))
    request.rack_request.path_info = 'ruil.html'
    request.generated_data = {:v => 'HTML'}
    @templates << ['/tmp/spec/ruil.desktop.tenjin.html', '<p>#{@v}</p>', request]
    request = Ruil::Request.new(Rack::Request.new({}))
    request.rack_request.path_info = 'ruil.xhtml'
    request.generated_data = {:v => 'XHTML'}
    @templates << ['/tmp/spec/ruil.desktop.tenjin.xhtml', '<p>#{@v}</p>', request]
    @templates.each do |t|
      template = File.new(t[0], 'w')
      template << t[1]
      template.close
    end
    # @layout = '/tmp/layout.'
    # File.new(t[0], 'w')
    # @layo << t[1]
    # template.close
    # Define responders
    @responder1 = Ruil::HTMLResponder.new('/tmp/spec/ruil')
    # @responder2 = Ruil::HTMLResponder.new('/tmp/ruil', @layout)
  end

  after(:all) do
    Dir['/tmp/spec/*'].each { |f| File.delete f }
    Dir.delete '/tmp/spec'
  end

  it 'should respond files without layout' do
    @templates.each do |template|
      response = @responder1.call(template[2])
      response.status.should == 200
      response.body.should == ["<p>#{template[2].generated_data[:v]}</p>"]
      case template[2].rack_request.path_info
      when /.html$/
        response.header['Content-Type'].should == 'text/html'
      when /.xhtml$/
        response.header['Content-Type'].should == 'application/xhtml+xml'
      else
        raise
      end
    end
  end

  # it 'should respond using a html file with layout' do
  #   response = @responder1.call(@request2)
  #   response.status.should == 200
  #   response.body.should == ['<html><body><p>HTML: hello world<p></body></html>']
  #   response.header['Content-Type'].should == 'text/html'
  # end

end
