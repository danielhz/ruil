# module Ruil

#   class Widget
#     def initialize(options = {})
#       if Hash === options
#         @templates_dir = options[:templates_dir]
#         if @templates_dir.nil?
#           if defined?(APPLICATION_PATH).nil?
#             raise "APPLICATION_PATH is undefinded"
#           else
#             @templates_dir = File.join(APPLICATION_PATH, "dynamic", "templates", "session_widget")
#           end
#         end
#       end
#       setup_actions
#     end

#     def setup_actions
#     end

#     def render(method, url_pattern_suffix, template, layout = nil)
#       Ruil::Resource.new(method, "#{@url_pattern_prefix}/#{url_pattern_suffix}", layout) do |resource|
#         Dir[File.join(@templates_dir, "#{template}.*.*.*")].each do |file|
#           resource << Ruil::Template.new(file, layout) if /\.(html|xhtml|css|js)$/ === file
#         end
#         if block_given?
#           resource.content_generator = Proc.new { |e| yield e }
#         end
#       end
#     end

#     def redirect(request_methods, url_pattern_suffix, redirect_to)
#       Ruil::Register << Ruil::Redirector.new(request_methods, redirect_to) do |env|
#         yield env if block_given?
#       end
#     end
#   end

# end
