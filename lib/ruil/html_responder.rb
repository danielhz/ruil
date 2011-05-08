require 'rubygems'
require 'tenjin'

module Ruil

  # {Ruil::HTMLResponder} objects implement receive requests and respond
  # with Rack::Response where bodies are HTML documents and the media
  # type is "text/html" or "application/xhtml+xml".
  class HTMLResponder

    # Initialize a new template object using the template file name
    # prefix. Also a layout could be defined with the template.
    #
    # Template files name must follow the pattern "foo.key.tenjin.html",
    # where foo is the name of the template, tipically related with
    # the resource, key is the key that indentify different
    # templates for the same resource and html is the indentifier
    # for the template media type.
    #
    # We use distinct templates for the same resource to send
    # different representations of the resource depending the client
    # user agent and preferences.
    def initialize(file_prefix, layout = nil)
      @templates = []
      Dir[file_prefix + ".*.*.*"].select{ |f| ! (/\.cache$/ === f) }.each do |file|
        a = File.basename(file).split('.')
        # Mode
        mode = a[1].to_sym
        # Media type
        media_type = case a[3]
                     when "html"
                       "text/html"
                     when "xhtml"
                       "application/xhtml+xml"
                     else
                       next
                     end
        # Add template
        engine = case a[2]
                 when "tenjin"
                   require "tenjin"
                   Tenjin::Engine.new({:layout => layout})
                 else
                   raise "Template engine unknown #{a[2]}"
                 end
        @templates << {
          :mode       => mode.to_sym,
          :engine     => engine,
          :file       => file,
          :media_type => media_type,
          :suffix     => a[3].to_sym
        }
      end
    end

    # Creates a resource representation using a template for the
    # data contained in the request.
    #
    # @param [Ruil::Request] request the request to respond.
    # @return [Rack::Response] the response.
    def call(request)
      path_info = request.rack_request.path_info
      suffix = path_info.sub(/^.*\./, '')
      suffix = 'html' if suffix == path_info
      template = @templates.select{
        |t| t[:suffix] == suffix.to_sym and t[:mode] == mode(request)
      }.map.first

      unless template.nil?
        body = template[:engine].render(template[:file], request.generated_data)
        Rack::Response.new(body, 200, {'Content-Type' => template[:media_type]})
      else
        return false
      end
    end

    def mode(request)
      r = request.rack_request
      r.session[:mode] = r.params['mode'].to_sym unless r.params['mode'].nil?
      r.session[:mode] = :desktop if r.session[:mode].nil?
      r.session[:mode]
    end

  end

end
