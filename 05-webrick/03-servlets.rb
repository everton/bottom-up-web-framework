#!/usr/bin/env ruby

require_relative 'config/app'

server = App.server

class Echo < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    response.status = 200
    response['Content-Type'] = 'text/html'
    response.body = "<h1>#{request.path}</h1>"
  end
end

server.mount '/', Echo

server.start
