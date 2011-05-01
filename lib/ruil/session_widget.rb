# module Ruil

#   class SessionWidget < Ruil::Widget

#     # Initialize a new RuilSessionWidget
#     def initialize(options = {})
#       if Hash === options
#         # Set @path_prefix
#         @path_prefix = options[:path_prefix] || "/session_widget/"
#         # Set @logout_redirects_to
#         @logout_redirects_to = options[:logout_redirects_to] || "/front.html"
#         # Set @users_collection
#         @users_collection = options[:users_collection]
#         if @users_collection.nil?
#           if defined?(DB).nil?
#             raise "DB undefined"
#           else
#             @users_collection = DB['users']
#           end
#         end
#       end
#       super
#     end

#     def setup_actions
#       render "stylesheet", "stylesheet"
#       render "script", "script"
#       redirect "logout", @logout_redirects_to do
#         # Clean session
#       end
#       render "login", "login" do
#         # Authenticate
#       end
#       render "request", "request" do
#       end
#       render "check", "check" do
#         # Check code
#       end
#       render "update", "update" do
#       end
#     end

#   end
