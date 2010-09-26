require 'rubygems'
require 'tenjin'

module Ruil

  class TenjinTemplate

    @@engine = Tenjin::Engine.new

    def initialize(file)
      @file = file
    end

    def call(options)
      @@engine.render(@file, options)
    end

  end

end
