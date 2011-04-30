module Ruil

  # Each instance of {Ruil::PathInfoParser} matches path info strings
  # with a pattern and return variables matching it if
  # the pattern is matched. Else, it returns false.
  #
  # === Usage
  #
  #    parser = PathInfoParser.new('/foo/:type/:id')
  #    parser === '/foo/bar/1'      # => {:type => 'bar', :id => '1'}
  #    parser === '/foo/bar/3.js'   # => {:type => 'bar', :id => '3'}
  #    parser === '/foo'            # => false
  #    parser === '/bar'            # => false
  #
  class PathInfoParser

    # Initialize a new parser
    # 
    # @param pattern[String] the pattern to match
    def initialize(pattern)
      @pattern = pattern.split('/').map do |s|
       ( s[0,1] == ':' ) ? eval(s) : s
      end
      @pattern = ['', ''] if @pattern.empty?
    end

    # Match a path info.
    #
    # @param path_info[String] the path info to match.
    # @return [Hash,false] a hash with variables matched with the
    #   pattern or false if the path info doesn't match the pattern.
    def ===(path_info)
      s = path_info.split('/')
      s = ['', ''] if s.empty?
      s.last.gsub!(/\..*$/, '')
      return false unless s.size == @pattern.size
      matchs = {}
      s.each_index do |i|
        if Symbol === @pattern[i]
          matchs[@pattern[i]] = s[i]
        else
          return false unless @pattern[i] == s[i]
        end
      end
      matchs
    end

  end

end
