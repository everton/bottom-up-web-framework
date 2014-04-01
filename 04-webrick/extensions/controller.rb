#!/usr/bin/env ruby

require_relative 'string'

require_relative '../config/app'

class Controller < WEBrick::HTTPServlet::AbstractServlet
  attr_accessor :request, :response, :params

  def do_GET(request, response)
    @request, @response = request, response

    match_GET_action_and_params!

    action = params[:action]
    return action_not_found unless action

    begin
      send action if respond_to? action
    rescue => e
      return server_error e
    end

    begin
      raise "UnknowTemplateFile: #{view_file}" unless File.exist? view_file

      view   = ERB.new(File.read(view_file))

      @response.status = 200
      @response['Content-Type'] = 'text/html'
      @response.body = view.result(binding)
    rescue => e
      return server_error e
    end
  end

  private
  def controller_name
    self.class.name.underscore
  end

  def view_file
    App.root.join 'app', 'views',
      controller_name.gsub(/_controller$/, ''),
      "#{params[:action]}.html.erb"
  end

  # Possible values:
  #   /users        => action: :index
  #   /users/new    => action: :new
  #   /users/1      => action: :show, id: 1
  #   /users/1/edit => action: :edit, id: 1
  def match_GET_action_and_params!
    @params = { controller: controller_name.to_sym }

    case request.path
    when '/users', '/users/'
      @params.merge! action: :index
    when '/users/new'
      @params.merge! action: :new
    when /\/users\/(\d+)\/edit/
      @params.merge! action: :edit, id: $1
    when /\/users\/(\d+)/
      @params.merge! action: :show, id: $1
    end
  end

  def action_not_found
    @response.status = 404
    @response['Content-Type'] = 'text/html'
    @response.body = "<h1>Action not found for #{@request.path}</h1>"
  end

  def server_error(error = nil)
    @response.status = 500
    @response['Content-Type'] = 'text/html'
    @response.body = "<h1>Error: #{error.message}</h1>\n#{error.backtrace}"
  end
end
