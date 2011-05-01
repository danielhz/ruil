require 'rubygems'
require 'rack'
require 'ruil/path_info_parser'
require 'ruil/register'

module Ruil

  # {Ruil::Resource} objects answer requests (see the method {#call}) with
  # an array following the Rack interface. If the request not match the
  # resource, +false+ is returned.
  # Also, a resource includes a set of templates to delegate the action of
  # rendering a resource.
  #
  # === Use example
  #
  # The next example shows how to create and use a resource.
  #
  #    resource = Resource.new('GET', "/index")
  #    puts resource.call(request)        # => the response to the request
  #
  # Every resource is automatically regitered into {Ruil::Register} when it
  # is created. Thus, you may use {Ruil::Register.call} to call resource
  # instead using {#call} directly.
  #
  #    resource = Resource.new('GET', "/index")
  #    puts Ruil::Register.call(request)  # => the response using the register
  #
  # === Templates
  #
  # The interface of templates consists in the +new+, +key+ and +call+ methods.
  # Classes that satisfy that interface are {Ruil::Template} and
  # {Ruil::JSONTemplate}. Every resource have a {Ruil::JSONTemplate} as a
  # default template.
  #
  #    resource = Resource.new('GET', "/index") do |res|
  #      Dir['path_to_templates/*'].each do |file|
  #        res << Ruil::Template.new(file)
  #      end
  #    end
  #
  # === Path patterns
  #
  # Path patterns are strings that are matched with the request path info.
  # Patterns may include named parameters accessibles via the hash that
  # the {Ruil::PathInfoParser#===} method returns after a match check.
  #   
  #    resource = Ruil::Resource.new(:get, "/users/:user_id/pictures/:picture_id")
  #    env['PATH_INFO'] = "/users/23/pictures/56"
  #    resource.call(env)    # matches are { :user_id => "232, :picture_id => "56" }
  #    env['PATH_INFO'] = "/users/23/pictures"
  #    resource.call(env)    # match is false
  class Resource

    # Methods that a resource responds.
    # 
    # @return [Array<String>]
    attr_reader :request_methods

    # Initialize a new resource.
    #
    # @param request_methods [String, Array<String>]
    #   indentify the request methods that this resource responds. Valid
    #   methods are: <tt>"GET"</tt>, <tt>"POST"</tt>, <tt>"PUT"</tt> and
    #   <tt>"DELETE"</tt>.
    #
    # @param path_pattern [String]
    #   defines a pattern to match paths.
    #   Patterns may include named parameters accessibles via the hash that
    #   the {Ruil::PathInfoParser#===} method returns after a match check.
    #
    # @param authorizer [lambda(Ruil::Request)]
    #   A procedure that checks if the user is allowed to access the resource.
    #
    # @param responders [Array<Responder>] an array with responders.
    def initialize(request_methods, path_pattern, authorizer = nil, responders = [], &block)
      # Set request methods
      @request_methods =
        case request_methods
        when String
          [request_methods]
        when Array
          request_methods
        else
          raise "Invalid value for request_methods: #{request_methods.inspect}"
        end
      # Set the path info parser
      @path_info_parser = Ruil::PathInfoParser.new(path_pattern)
      # Set the authorizer method
      @authorizer = authorizer
      # Set responders
      @responders = [Ruil::JSONResponder.instance] + responders
      # Block that generates data
      @block = Proc.new { |request| yield request } if block_given?
      # Register
      Ruil::Register << self
    end

    # Respond a request
    #
    # @param request [Rack::Request] a request to the resource.
    # @return [Rack::Response] a response for the request.
    def call(rack_request)
      path_info = rack_request.path_info
      path_info_params = ( @path_info_parser === path_info )
      return false unless path_info_params
      unless @authorizer.nil?
        return @autorizer.unauthorized unless @authorizer.authorize(request)
      end
      request = Ruil::Request.new(rack_request)
      request.generated_data[:path_info_params] = path_info_params
      @block.call(request) unless @block.nil?
      @responders.each do |responder|
        response = responder.call(request)
        return response if response
      end
      raise "Responder not found for #{request.inspect}"
    end

  end

end
