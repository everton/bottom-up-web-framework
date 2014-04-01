#!/usr/bin/env ruby

require 'pathname'
require 'webrick'
require 'erb'

class App
  class << self
    def root
      Pathname.new File.realpath(File.join(File.dirname(__FILE__), '..'))
    end

    def server
      server = WEBrick::HTTPServer
        .new Port: 8000, DocumentRoot: root.join('public')

      # Providing a way to stop tthe server
      trap 'INT' do server.shutdown end

      return server
    end
  end
end
