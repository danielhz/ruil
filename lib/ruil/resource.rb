require 'rubygems'

module Ruil

  # Ruil::Resource objects include methods to identify if a resource is requested
  # and to answer that request. Also, a resource includes a set of templates to
  # delegate the action of rendering a resource.
  #
  # ==== Use example
  #
  # The next example shows how to create and use a resource. The interface of
  # of templates consists in the new, key and call methods. A class that
  # satisfy that interface is the Ruil::TenjinTemplate class.
  #
  #    # Create the resource
  #    resource = Resource.new do |res|
  #      Dir['path_to_templates/*.tenjin.html'].each do |f|
  #        res << Ruil::TenjinTemplate.new f
  #      end
  #    end
  #
  #    # Print the response for a request.
  #    if resource === env
  #      puts resource.call(env)
  #    end
  class Resource

    # Initialize a new resource.
    #
    # ==== Options:
    # 
    # - *:user_agent_parser* is an object with a method call that analize the
    #   request to get the key for the template to use. The key is a symbol
    #   that identifies the user, like :desktop, :mobile or :iphone.
    #
    # - *:path_pattern* is an object with a === method that checks
    #   if a string match the pattern. Default :path_pattern is //.
    #
    # - *:authorize_proc* is an object with a method call that checks if
    #   the user is allowed to access to this resource.
    #
    # - *:unauthorized_proc* is an object with a method call to delegate
    #   the call method of this resource if the user is not allowed to access to
    #   this resource.
    def initialize(options = {}, &block)
      @templates         = {}
      @user_agent_parser = options[:user_agent_parser] || Proc.new { |env| :desktop }
      @path_pattern      = options[:path_pattern] || //
      @authorize_proc    = options[:authorize_proc] || Proc.new{ |env| true }
      @unauthorized_proc = options[:unauthorized_proc] || Proc.new{ |env| Resource.redirect('/unauthorized') }
      yield self
    end

    # Check if the resource match an URL.
    def ===(env)
      @path_pattern === env['PATH_INFO']
    end

    # Add a template to the templates managed for this resource.
    # Each templated is asociated with the key that the
    # :user_agent_parser get (see the initialize options parameter).
    def <<(template)
      @templates[template.key] = template
    end

    # Build options to render the resource.
    # Options are passed to the template when rendering the resource.
    def options(env)
      {
        :env => env
      }
    end

    # Call the resource and get the response.
    def call(env)
      if @authorize_proc.call(env)
        render_html(env)
      else
        @unauthorized.call(env)
      end
    end

    # Render the resource.
    def render(env)
      template = @templates[@user_agent_parser.call(env) || @templates.keys.sort.first]
      content = template.call(options(env))
      [200, {"Content-Type" => template.media_type}, [content]]
    end

  end

end
