#!/usr/bin/env ruby

require 'webrick'

root   = File.expand_path File.join File.dirname(__FILE__), './public'
server = WEBrick::HTTPServer.new Port: 8000, DocumentRoot: root

# Providing a way to stop tthe server
trap 'INT' do server.shutdown end

server.start
