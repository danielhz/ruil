module Ruil

  # {Ruil::Authorizer} allow us to define an ACL.
  # 
  # === Access rules
  #
  # Each access rule is composed by a pattern and a condition to check.
  #
  # The next example shows a rule authorizing all requests mathing the
  # path pattern '/foo/:bar'.
  # 
  #     Ruil::Authorizer << '/foo/:bar'
  #
  # The next example shows a rule authorizing only requests associated to
  # logged users.
  #
  #     Ruil::Authorizer << '/foo/:bar', lambda { |r| not r.session[:user].nil? }
  #
  # === Reject action
  #
  # By default rejected requests are redirected to '/login'. You can change
  # that behavior:
  #
  #     Ruil::Authorizer.rejector lambda { |r| ok :text, 'Forbidden resource!' }
  #
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
