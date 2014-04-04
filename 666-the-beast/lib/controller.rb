#!/usr/bin/env ruby

class Controller
  attr_accessor :request, :response, :params

  def call(request, response, params)
    @request, @response, @params = request, response, params

    begin
      send params[:action] if respond_to? params[:action]
    rescue => e
      return server_error e
    end

    begin
      raise "UnknowTemplateFile: #{view_file}" unless File.exist? view_file

      view   = ERB.new(File.read(view_file))

      @response.status = 200
      @response['Content-Type'] = 'text/html'
      @response.body = [view.result(binding)]
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

  def action_not_found
    App::LOGGER.debug "ActionNotFound: #{@request.path}"

    @response.status = 404
    @response['Content-Type'] = 'text/html'
    @response.body = ["<h1>Action not found for #{@request.path}</h1>"]
  end

  def server_error(error = nil)
    App::LOGGER.debug "ServerError: #{error.message}\n#{error.backtrace}"

    @response.status = 500
    @response['Content-Type'] = 'text/html'
    @response.body = ["<h1>Error: #{error.message}</h1>\n#{error.backtrace}"]
  end
end
