#!/usr/bin/env ruby

require_relative 'config/app'

server = App.server

server.mount_proc '/' do |req, res|
  res.body = "<h1>Hello world - #{Time.now}</h1>"
end

server.start
