#!/usr/bin/env ruby

require 'rack'

class HelloWorld
  def call(env)
    request = Rack::Request.new(env)

    body_lines = [
      "<h1>Hello Rack!</h1>",
      request.params.to_s
    ]

    [ 200, { "Content-Type" => "text/html" }, body_lines ]
  end
end

Rack::Handler::WEBrick.run HelloWorld.new, Port: 8000
