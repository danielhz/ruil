require 'rubygems'

module Ruil

  # Ruil::Delegator objects delegate requests to objects that also have
  # the methods call and ===.
  #
  # ==== Usage
  #
  #    # Create a new delegator with to resources: r1 and r2.
  #    delegator = RuilDelegator.new do |d|
  #      d << r1
  #      d << r2
  #    end
  #
  #    # Print the resource response to a request.
  #    if delegator === env
  #      puts delegator.call env
  #    end
  class Delegator

    # Initialize a delegator.
    #
    # ==== Options:
    #
    # - *:user_agent_parser* is a procedure that receive a environment and get a
    #   template key. If no procedure is given, it uses one that always
    #   returns :desktop.
    #
    # - *:default* is procedure to delegate when the request matches no
    #   resources. If no default action is entered, the default is redirection
    #   to '/' path.
    #
    # - *:path_pattern* is an object with a === method that checks
    #   if a string match the pattern. Default :path_pattern is //.
    def initialize(options = {}, &block)
      @user_agent_parser = options[:user_agent_parser] || Proc.new{ |env| :desktop }
      @default_action    = options[:default_action] || Proc.new do |env|
        [ 302, {"Content-Type" => "text/html", 'Location'=> '/' }, [] ]
      end
      @path_pattern      = options[:path_pattern] || //
      @resources         = []
      yield self
    end

    # Add a resource to the delegator.
    def <<(resource)
      @resources << r
    end

    # Call the delegator and delegates the request to some resource.
    def call(env)
      @resources.each { |r| return r.call(env) if r === env }
      @default_action.call(env)
    end

  end

end
