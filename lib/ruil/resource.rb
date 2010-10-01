require 'rubygems'

module Ruil

  class Resource

    # A regular expression to hear
    attr_reader :path_pattern

    # A regular expression to search templates
    attr_reader :template_pattern

    # Initialize a new resource.
    #
    # Options:
    # - user_agent_parser: is an object with a method call that analize the
    #     request to get the key for the template to use.
    def initialize(options = {}, &block)
      @templates         = {}
      @user_agent_parser = options[:user_agent_parser] || Proc.new { |env| :desktop }
      @path_pattern      = options[:path_pattern] || '/'
      @template_pattern  = options[:template_pattern] || '*.*.html'
      @authorize_proc    = options[:authorize_proc] || Proc.new{ |env| true }
      @unauthorized_proc = options[:unauthorized_proc] || Proc.new{ |env| Resource.redirect('/unauthorized') }
      yield self
    end

    # Add a template to the templates list.
    def add_template(key, template)
      @templates[key] = template
    end

    # Build options to render the resource.
    def options(env)
      {
        :env => env
      }
    end

    # Call the resource
    def call(env)
      if @authorize_proc.call(env)
        render_html(env)
      else
        @unauthorized.call(env)
      end
    end

    # Render
    def render_html(env)
      template = @templates[@user_agent_parser.call(env) || @templates.keys.sort.first]
      content = template.call(options(env))
      [200, {"Content-Type" => "text/html"}, [content]]
    end

    # Redirect
    def self.redirect(url)
      [ 302, {"Content-Type" => "text/html", 'Location'=> url }, [] ]
    end

  end

end
