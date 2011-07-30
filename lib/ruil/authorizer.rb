module Ruil

  # {Ruil::Authorizer} allow us to define an ACL.
  # 
  # Each access rule is composed by a pattern to check 
  module Authorizer
    include Ruil::Controller

    # Access rules.
    @@rules = {}

    # The action to respond when access is denegated.
    @@rejector = lambda { |request| redirect(request, '/login') }

    # Creates a new access rule.
    def self.<<(patterns, condition = nil)
      # Set the condition.
      condition = condition || lambda { |request| true }
      # Add this rule to the list
      case patterns
      when Array
        patterns.each { |p| @@rules[p] = condition }
      when String
        @@rules[patterns] = condition
      end
    end

    # Authorize access for an user.
    def self.call(request, responder)
      unless ( rule = @@rules[request[:path_info_pattern]] ).nil? or rule.call(request)
        # Deny access.
        @rejector.call request
      else
        # Allow access
        responder.call request
      end
    end

    # Set the action to perform when access is denied.
    def self.rejector(responder)
      @@rejector = responder
    end

  end

end
