require 'rubygems'
require 'json'
require 'singleton'

module Ruil

  # The {Ruil::JSONResponder} singleton object recive a request and gets
  # a Rack::Response serializing the {Ruil::Request#generated_data} in the 
  # JSON format as the response body.
  #
  # === Usage
  #
  #    request.generated_data             # => {'some':['data']}
  #    responder = JSONResponder.new
  #    response  = responder.call(request)
  #    response.status                    # => 200
  #    response.header['Content-Type']    # => "application/json"
  #    response.body                      # => "{'some':['data']}"
  #
  class JSONResponder
    include Singleton

    # Responds a request.
    # @param request[Ruil::Request] the request
    # @return [Rack::Response] the response
    def call(request)
      Rack::Response.new([request.generated_data.to_json],
                         200, {'Content-Type' => 'application/json'})
    end

  end

end
