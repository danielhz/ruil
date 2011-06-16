require 'rubygems'
require 'json'
require 'rack'

module Ruil

  # Logger store records as lines in a file. Each line is coded in
  # JSON format.
  class Logger

    @@file_name = nil
    @@log_file  = nil

    # Create a new logger.
    def initialize(app, dir)
      @app        = app
      @dir        = dir
    end

    # Set the log_file using the current date.
    def log_file
      file_name = Time.now.strftime(File.join(@dir, '%Y-%m-%d.log'))
      unless @@file_name == file_name
        puts "new log file #{@@file_name}"
        @@file_name = file_name
        @@log_file.close unless @@log_file.nil?
        @@log_file = File.new(@@file_name , 'a+')
      end
      @@log_file
    end

    # Call the logger.
    def call(env)
      request = Rack::Request.new(env)
      status, header, body = @app.call(env)
      log_entry = {
        'timestamp'  => Time.now.to_i,
        'status'     => status,
        'path_info'  => request.path_info,
        'params'     => request.params,
        'url'        => request.url,
        'remote_ip'  => request.ip,
        'user_agent' => request.user_agent,
        'session_id' => request.session_options[:id]
      }
      unless request.session[:user].nil?
        log_entry['user_id'] = request.session[:user][:oid]
      end
      log_file << log_entry.to_json + "\n"
      [status, header, body]
    end
  end
end
