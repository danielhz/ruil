require 'rubygems'
require 'rack'

module Ruil

  # {Ruil::Resource} objects answer requests (see the method {#call}) with an array
  # following the Rack interface. If the request not match the resource, +false+ is
  # returned.
  # Also, a resource includes a set of templates to delegate the action of rendering
  # a resource.
  #
  # === Use example
  #
  # The next example shows how to create and use a resource.
  #
  #    resource = Resource.new(:get, "/index")
  #    puts resource.call(request)          # => the response to the request
  #
  # Every resource is automatically regitered into {Ruil::Register} when it is created.
  # Thus, you may use {Ruil::Register.call} to call resource. instead using
  # {#call} directly.
  #
  #    resource = Resource.new(:get, "/index")
  #    puts Ruil::Register.call(request)    # => the response using the register
  #
  # === Templates
  #
  # The interface of templates consists in the +new+, +key+ and +call+ methods.
  # Classes that satisfy that interface are {Ruil::Template} and {Ruil::JSONTemplate}.
  # Every resource have a {Ruil::JSONTemplate} as a default template.
  #
  #    resource = Resource.new(:get, "/index") do |res|
  #      Dir['path_to_templates/*'].each do |file|
  #        res << Ruil::Template.new file
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

    # An procedure to perform before rendering the resource.
    # The output of this procedure is the input of {#content_generator}.
    # @return [Proc] the procedure
    attr_accessor :action_performer

    # A procedure to generate the content.
    # The input of this procedure is the output of {#action_performer}.
    # @return [Proc] the procedure
    attr_accessor :content_generator

    # An procedure to check if a user is authorized to access the resource.
    # @return [Proc] the procedure
    attr_accessor :authorizer

    # An action to delegate when the user is unauthorized to access the resource.
    # @return [Proc] the procedure
    attr_accessor :unauthorized_proc

    # An procedure that gets the apropiate template key for the user agent.
    # @return [Proc] the procedure
    attr_accessor :user_agent_parser

    attr_accessor :request_methods

    # Initialize a new resource.
    #
    # @param [Symbol, Array<Symbol>] request_methods
    #   indentify the request methods that this resource responds.
    #   Valid symbols for request methods are: <tt>:get</tt>, <tt>:post</tt>,
    #   <tt>:put</tt> and <tt>:delete</tt>.
    #
    # @param [String] path_pattern
    #   defines a pattern to match paths.
    #   Patterns may include named parameters accessibles via the hash that
    #   the {Ruil::PathInfoParser#===} method returns after a match check.
    def initialize(request_methods, path_pattern, &block)
      @templates         = {}
      self << Ruil::JSONTemplate.instance
      @request_methods   = case request_methods
                           when Symbol
                             [request_methods]
                           when Array
                             request_methods
                           else
                             raise 'Invalid value for request_methods: #{request_methods.inspect}'
                           end
      @path_info_parser  = Ruil::PathInfoParser.new path_pattern
      @authorizer        = Proc.new{ |e| true }
      @action_performer  = Proc.new{ |e| e }
      @content_generator = Proc.new{ |e| {} }
      @user_agent_parser = Proc.new do |e|
        if /\.json$/ === e[:request].path_info
          :json
        else
          :desktop
        end
      end
      @unauthorized_proc = Proc.new do |request,path_info_params|
        [ 302, {"Content-Type" => "text/html", 'Location'=> "/unauthorized" }, [] ]
      end
      yield self if block_given?
      Ruil::Register << self
    end

    # Add a template to the templates managed for this resource.
    # Each template is asociated with a key that the {#user_agent_parser} select.
    #
    # @param [Ruil::Template] template a template.
    def <<(template)
      @templates[template.key] = template
    end

    # Render the resource.
    #
    # @param [Hash,Rack::Request] request
    #   a request to the resource.
    def call(request)
      e = {}
      e[:request] = case request
                    when Hash
                      Rack::Request.new(request)
                    when Rack::Request
                      request
                    else
                      raise "Invalid request: #{request.inspect}"
                    end
      e[:path_info_params] = ( @path_info_parser === e[:request].path_info )
      return false unless e[:path_info_params]
      @unauthorize_proc.call(e) unless @authorizer.call(e)
      template = @templates[@user_agent_parser.call(e) || :json]
      body = template.call(@content_generator.call(@action_performer.call(e)))
      [200, {"Content-Type" => template.media_type}, [body]]
    end

  end

end
