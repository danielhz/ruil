
module Ruil

  # {Ruil::NotFoundResponder} respond with a not found message.
  module NotFoundResponder

    # Creates a not-found response to a request.
    #
    # @param [Ruil::Request] request the request to respond.
    # @return [Rack::Response] the response.
    def self.call(request)
      method = request.rack_request.method
      url    = request.rack_request.url
      body   = "Resource not found: #{method} #{url}"
      Rack::Response.new(body, 200, {'Content-Type' => 'text/plain'})
    end

  end

end
