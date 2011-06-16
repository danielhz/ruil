
module Ruil

  # {Ruil::NotFoundResponder} respond with a not found message.
  module NotFoundResponder

    # Creates a not-found response to a request.
    #
    # @param [Ruil::Request] request the request to respond.
    # @return [Rack::Response] the response.
    def self.call(request)
      rack_request = case request
                     when Ruil::Request
                       request.rack_request
                     when Rack::Request
                       request
                     end
      body   = "Resource not found: #{rack_request.request_method} #{rack_request.url}"
      Rack::Response.new(body, 404, {'Content-Type' => 'text/plain'})
    end

  end

end
