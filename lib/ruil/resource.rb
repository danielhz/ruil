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
    # @param pattern [String]
    #   defines a pattern to match paths.
    #   Patterns may include named parameters accessibles via the hash that
    #   the {Ruil::PathInfoParser#===} method returns after a match check.
    def initialize(request_methods, pattern, &block)
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
      @path_info_parser = Ruil::PathInfoParser.new(pattern)
      # Block that generates the response
      if block_given?
        @block = lambda { |request| yield request }
      else
        raise 'Block is obligatory!'
      end
      # Register it
      Ruil::Register << self
    end

    # Respond a request
    #
    # @param request [Rack::Request] a request to the resource.
    # @return [Array] a response for the request in the format [status, headers, [body]].
    def call(request)
      if request[:path_info_params] = ( @path_info_parser === request.path_info )
        Ruil::Authorizer.call request, @block
      else
        false
      end
    end

  end

end
