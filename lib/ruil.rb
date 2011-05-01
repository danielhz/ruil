require 'rack'

# Dir[File.dirname(File.expand_path(__FILE__)) + '/**/*.rb'].each do |f|
#   require f
# end

require 'ruil/path_info_parser.rb'
require 'ruil/request.rb'
require 'ruil/json_responder.rb'
require 'ruil/html_responder.rb'
require 'ruil/redirector.rb'
require 'ruil/register.rb'
require 'ruil/resource.rb'
