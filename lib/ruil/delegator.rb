require 'rubygems'

module Ruil

  class Delegator

    # Initialize a delegator.
    #
    # Options:
    # - +user_agent_parser+ is a precedure that get a template key from the enviroment.
    #   If no procedure is given, it uses a procedure that always returns :desktop.
    # - +template_engine+ is a class that allows to build template objects using a file
    #   name as parameter.
    # - +template_dir+ is a directory where templates are stored.
    # - +default_action+ is an action to delegate when the request matches no resources.
    def initialize(options = {}, &block)
      @user_agent_parser = options[:user_agent_parser] || Proc.new{ |env| :desktop }
      @template_engine   = options[:template_engine]
      @template_dir      = options[:template_dir]
      @default_action    = options[:default_action] || Proc.new do |env|
        [ 302, {"Content-Type" => "text/html", 'Location'=> '/' }, [] ]
      end
      @resources         = []
      yield self
    end

    # Add a resource to the delegator
    def add_resource(resource_class, options = {})
      opts = { :user_agent_parser => @user_agent_parser }.merge(options)
      resource_class.new(opts) do |r|
        Dir[File.join(@template_dir, r.template_pattern)].each do |file|
          user_agent = File.basename(file).split('.')[1]
          template = @template_engine.new(file)
          r.add_template user_agent.to_sym, template
        end
        @resources << [r.path_pattern, r]
      end
    end

    # Call the delegator and delegates the request to some resource.
    def call(env)
      @resources.each do |path_pattern, proc|
        return proc.call(env) if path_pattern === env['PATH_INFO']
      end
      @default_action.call(env)
    end

  end

end
