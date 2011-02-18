require 'rubygems'
require 'json'
require 'singleton'

module Ruil

  # {Ruil::JSONTemplate} objects implement the interface needed by
  # {Ruil::Resource} to render the bodies of HTTP responses. That
  # interface includes the methods: {#media_type}, {#key} and {#call}.
  #
  # === Usage
  #
  #    template = JSONTemplate.new
  #    template.media_type                # => "application/json"
  #    template.key                       # => :json
  #    template.call({:some => ['data']}) # => "{'some':['data']}"
  #
  class JSONTemplate
    include Singleton

    # Gets the template media type (allways 'application/json').
    # @return [String] the JSON media type
    def media_type
      "application/json"
    end

    # Gets the template key (allways +:json+).
    # @return [Symbol] the template key
    def key
      :json
    end

    # Creates a resource representation using the template. The
    # options parameter is a hash with the data to fill the template.
    #
    # @param [Hash] content
    #   data to fill the template
    #
    # @return [String] the template filled with the content data.
    def call(content)
      content.to_json
    end

  end

end
