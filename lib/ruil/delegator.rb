require 'rubygems'

module Ruil

  class Delegator

    # Initialize a delegator
    def initialize(user_agent_parser, template_dir, template_engine, &block)
      @user_agent_parser = user_agent_parser
      @template_engine   = template_engine
      @template_dir      = template_dir
      @resources         = []
      yield self
    end

    # Default action
    def default(env)
      [ 302, {"Content-Type" => "text/html", 'Location'=> '/' }, [] ]
    end

    def add_resource(resource_class)
      resource_class.new(@user_agent_parser) do |r|
        Dir[File.join(@template_dir, r.template_pattern)].each do |file|
          user_agent = File.basename(file).split('.')[1]
          template = @template_engine.new(file)
          r.add_template user_agent.to_sym, template
        end
        @resources << [r.path_pattern, r]
      end
    end

    # Call method
    def call(env)
      @resources.each do |path_pattern, proc|
        return proc.call(env) if path_pattern === env['PATH_INFO']
      end
      default(env)
    end

  end

end
