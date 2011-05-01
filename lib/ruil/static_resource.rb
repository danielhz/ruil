require 'rubygems'
require 'rack'
require 'ruil/register'


module Ruil

  # {Ruil::StaticResource} objects answer requests with static files.
  class StaticResource

    # Initialize a new {Ruil::StaticResource}.
    #
    # @param authorizer [lambda(Ruil::Request)]
    #   A procedure that checks if the user is allowed to access the resource.
    def initialize(authorizer = nil, &block)
      # Setup
      @authorizer = authorizer
      @files = {}
      yield self if block_given?
      # Register
      Ruil::Register << self
    end

    # Methods that a resource responds.
    # 
    # @return [Array<String>]
    def request_methods
      ['GET']
    end

    # Add a static file
    #
    # @param file_name [String] the path in the file system.
    # @param file_uri [String] the path from client request.
    # @param content_type [String] the mime type.
    def add(file_name, file_uri, content_type)
      file = File.new(file_name)
      body = file.read
      file.close
      @files[file_uri] = {
        :body => [body],
        :content_type => content_type
      }
    end

    # Respond a request
    #
    # @param request [Rack::Request] a request to the resource.
    # @return [Rack::Response] a response for the request.
    def call(rack_request)
      path_info = rack_request.path_info
      file = @files[path_info]
      return false if file.nil?
      unless @authorizer.nil?
        request = Ruil::Request.new(rack_request)
        return @autorizer.unauthorized unless @authorizer.authorize(request)
      end
      Rack::Response.new(file[:body], 200, {'Content-Type' => file[:content_type]})
    end

  end

end
