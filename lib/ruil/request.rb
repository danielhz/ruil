module Ruil

  # Instances of {Ruil::Request} encapsulate Rack::Requests
  # and extend it with data generated when processing the request.
  #
  # === Usage
  #
  #     rack_request = Rack::Request.new
  #     ruil_request = Ruil::Request.new(rack_request)
  #     ruil_request.rack_request              # => rack_request
  #     ruil_request.generated_data            # => {}
  #     ruil_request.generated_data[:x] = "y"
  #     ruil_request.generated_data            # => {:x => "y"}
  #     ruil_request.html_mode                 # => :desktop
  #
  class Request

    # The generated data.
    # @return [Hash]
    attr_accessor :generated_data

    # The rack request
    # @return [Rack::Request]
    attr_accessor :rack_request

    # Initialize a new Ruil::Request unsing a Rack::Request.
    # @param request[Rack::Request] the request to be encapsulated.
    def initialize(request)
      @rack_request   = request
      @generated_data = {}
    end

    # Return the mode for the view (:desktop, :mobile,...).
    # @return [Symbol]
    def html_mode
      if @html_mode.nil?
        # TODO: Get it from session
        # TODO: Get it from device parser
        @html_mode = :desktop
      end
      @html_mode
    end
  end

end
