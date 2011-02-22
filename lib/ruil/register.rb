module Ruil

  # Ruil::Register module allow us to register resources. When a Ruil::Resource
  # object is created it is automatically registered using the +register+ method.
  # The +call+ method answer a request with the first registered resource that
  # match the request. Matches are checked using the order of resource registrations.
  module Register

    @@resources = {
      'GET'    => [],
      'POST'   => [],
      'PUT'    => [],
      'DELETE' => []
    }

    # Register a resource.
    def self.<<(resource)
      resource.request_methods.each do |request_method|
        @@resources[request_method] << resource
      end
    end

    # Answer a request with the response of the matched resource for that request.
    def self.call(request_or_env)
      case request_or_env
      when Rack::Request
        request = request_or_env
      when Hash
        request = Rack::Request.new(request_or_env)
      else
        raise "Invalid request: #{request_or_env.inspect}"
      end
      p request.request_method
      p @@resources
      @@resources[request.request_method].each do |resource|
        response = resource.call(request)
        return response if response
      end
      raise "No resource matching the request"
    end

  end

end
