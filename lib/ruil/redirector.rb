module Ruil

  # {Ruil::Redirector} instances redirects requests to other resources.
  #
  # === Usage
  #
  # Tipically it could be used when access is unauthorized.
  #
  #     rack_request = Rack::Request.new({})
  #     rack_request.path_info = '/unauthorized_url'
  #     ruil_request = Ruil::Request.new(rack_request)
  #     response = Ruil::Redirector.new('/login').call(ruil_request)
  #     response.status              # => 302
  #     response.header['Location']  # => "/login?redirected_from=/unauthorized_url"
  #
  class Redirector

    # Initialize a {Ruil::Redirector}.
    def initialize(redirect_to)
      @redirect_to = redirect_to
    end

    # Responds a request with a redirection.
    # @param request[Ruil::Request] the request.
    # @return [Rack::Response] the response.
    def call(request)
      location_suffix = "redirected_from=" + request.rack_request.path_info
      location_sep    = case @redirect_to; when /\?$/; ''; when /\?.+/; '&'; else '?'; end
      location        = @redirect_to + location_sep + location_suffix

      Rack::Response.new([], 302, { 'Location' => location })
    end

  end

end
