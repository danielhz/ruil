module Ruil

  class PathInfoParser

    def initialize(pattern)
      @pattern = pattern.split('/').map do |s|
       ( s[0,1] == ':' ) ? eval(s) : s
      end
    end

    def ===(path_info)
      s = path_info.split('/')
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
