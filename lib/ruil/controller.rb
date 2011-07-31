
module Ruil

  # The module {Ruil::Controller} allow us to a group the creation of resources
  # in classes.
  #
  # === Usage
  # 
  #     class MyController
  #       include Ruil::Controller
  #
  #       resource 'GET', '/mycontroller/:your_name' do |request|
  #         ok :text, 'hello ' + request[:path_info_params][:your_name]
  #       end
  #     end
  #
  module Controller

    @@content_types = {
      :html  => 'text/html',
      :xhtml => 'application/xhtml+xml',
      :text  => 'plain/text',
      :json  => 'application/json'
    }

    # The method {Ruil::Controller#resource} creates a new {Ruil::Resource}
    # to answer requests matching the specific methods and url pattern.
    #
    # @param methods
    # @param pattern
    def resource(methods, pattern, acl = false, &block)
      Ruil::Resource.new(methods, pattern, acl, &block)
    end

    # Redirect the request to other URL.
    def redirect(request, url)
      headers = {
        'Location'=> url + ( /\?/ === url ? '&' : '?' ) + 'redirected_from=' + request.path_info
      }
      [302, headers, []]
    end

    # Respond OK
    #
    # @param body[String] the response body
    def ok(type, body, headers = {})
      # Apply custom skins.
      Ruil::Skin.call body if [:html, :xhtml].include? type
      # Setup headers.
      headers = {
        'ContentType' => @@content_types[type] || 'plain/text'
      }.merge(headers)
      # Respond.
      [200, headers, [body]]
    end

  end

end
