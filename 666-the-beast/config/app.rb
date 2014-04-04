require 'pathname'
require 'logger'
require 'yaml'

class App
  def self.root
    Pathname.new File.realpath(File.join(File.dirname(__FILE__), '..'))
  end

  BEAST_ENV        = ENV['BEAST_ENV'] || 'development'

  DB_CONFIG_FILE   = root.join 'config/database.yml'

  LOGGER_FILE      = File.open(root.join("logs/#{BEAST_ENV}.log"), 'a+')
  LOGGER_FILE.sync = true
  LOGGER           = Logger.new(LOGGER_FILE)

  def self.database_config
    configs = YAML.load(File.read(DB_CONFIG_FILE)) || {}
    configs = configs[App::BEAST_ENV]

    raise "Couldn't found database config for '#{App::BEAST_ENV}'" unless configs

    configs
  end

  def self.call(env)
    boot!

    request  = Rack::Request.new(env)
    response = Rack::Response.new

    params   = @routes.match request.path

    raise "No routes match: #{request.path}" unless params

    controller = find_controller(params[:controller])

    raise "Unknow controller: #{params[:controller]}" unless controller

    controller.new.call(request, response, request.params.merge(params))

    response.finish
  end

  def self.boot!
    App::LOGGER.info "Booting #{App::BEAST_ENV} environment"

    require root.join 'lib/extensions'
    require root.join 'lib/routes_mapper'
    require root.join 'lib/controller'
    require root.join 'lib/model'

    models.each do |model_file|
      App::LOGGER.info "Loading model: #{model_file}"
      load_or_require model_file
    end

    controllers.each do |controller_file|
      App::LOGGER.info "Loading controller: #{controller_file}"
      load_or_require controller_file
    end

    load_or_require root.join 'config/routes.rb'
  end

  def self.models
    Dir[ root.join 'app/models/*.rb' ]
  end

  def self.controllers
    Dir[ root.join 'app/controllers/*.rb' ]
  end

  def self.load_or_require(file)
    if BEAST_ENV == 'development'
      load file
    else
      require file
    end
  end

  def self.map_routes(&block)
    @routes = RoutesMapper.new

    yield(@routes)
  end

  def self.find_controller(controller)
    return unless controller

    "#{controller.to_s.camelize}Controller".constantize
  end
end
