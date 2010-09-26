require 'rubygems'

module Ruil

  class Resource
    
    # Initialize a new resource.
    #
    # Parameters:
    # - templates: a hash with procedures or objects with method call(options),
    #     used to generate the resource.
    # - user_agent_parser: is an object with a method call that analize the
    #     request to get the key for the template to use.
    def initialize(user_agent_parser, &block)
      @templates         = {}
      @user_agent_parser = user_agent_parser
      yield self
    end

    def add_template(key, template)
      @templates[key] = template
    end

    # The regular expression for the url of this resource.
    def path_pattern
      '/'
    end

    # The regular expression for the url of this resource.
    def template_pattern
      '*.*.html'
    end

    # Authorize the access to this resource.
    def authorize(env)
      true
    end

    # Build options to render the resource.
    def options(env)
      {
        :env => env,
        :template_key => template_key(env)
      }
    end

    # Selects the template key
    def template_key(env)
      @user_agent_parser.call(env) || @templates.keys.sort.first
    end

    # Selectes a template to render the resource
    def template(env)
      @templates[template_key(env)]
    end

    # Call the resource
    def call(env)
      if authorize(env)
        render_html(env)
      else
        unauthorized(env)
      end
    end

    # Action if the resource is unauthorized
    def unauthorized(env)
      redirect("/unauthorized")      
    end

    # Render
    def render_html(env)
      content = template(env).call(options(env))
      [200, {"Content-Type" => "text/html"}, [content]]
    end

    # Redirect
    def redirect(url)
      [ 302, {"Content-Type" => "text/html", 'Location'=> url }, [] ]
    end

  end

end
