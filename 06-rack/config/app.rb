require 'rack'

class App
  def call(env)
    request = Rack::Request.new(env)

    body_lines = [
      "<h1>Hello Rack!</h1>",
      request.params.to_s,
      "<h2>Current machine: #{`uname -a`}</h2>"
    ]

    [ 200, { "Content-Type" => "text/html" }, body_lines ]
  end
end
