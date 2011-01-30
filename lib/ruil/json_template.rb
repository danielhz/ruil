require 'rubygems'
require 'json'

module Ruil

  # Ruil::JSONTemplate objects implements the interface needed by
  # Ruil::Resource to render the bodies of HTTP responses. That
  # interface includes the methods: media_type, key and call.
  class JSONTemplate

    # Gets the template media type (allways 'application/json').
    def media_type
      "application/json"
    end

    # Gets the template key (allways 'json').
    def key
      :json
    end

    # Creates a resource representation using the template. The
    # options parameter is a hash with the data to fill the template.
    def call(options)
      options.to_json
    end

  end

end
