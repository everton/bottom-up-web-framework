#!/usr/bin/env ruby

require 'pathname'
require 'logger'
require 'yaml'

class App
  def self.root
    Pathname.new File.realpath(File.join(File.dirname(__FILE__), '..'))
  end

  BEAST_ENV      = ENV['BEAST_ENV'] || 'development'

  LOGGER_FILE    = root.join "logs/#{BEAST_ENV}.log"
  LOGGER         = Logger.new(File.open(LOGGER_FILE, 'w'))

  DB_CONFIG_FILE = root.join 'config/database.yml'

  def self.database_config
    configs = YAML.load(File.read(DB_CONFIG_FILE)) || {}
    configs = configs['development']

    raise "Couldn't found database config for '#{App::BEAST_ENV}'" unless configs

    configs
  end

  def self.boot!
    App::LOGGER.info "Booting #{App::BEAST_ENV} environment"

    require root.join 'lib/extensions'
    require root.join 'lib/model'

    models.each do |model_file|
      App::LOGGER.info "Loading model: #{model_file}"

      if BEAST_ENV == 'development'
        load model_file
      else
        require model_file
      end
    end
  end

  def self.models
    Dir[ root.join 'app/models/*.rb' ]
  end
end

App::LOGGER.info App.boot!

App::LOGGER.info '>>>>>>>>>>>>>>>>>>>>>>>'

App::LOGGER.info User.delete_all
App::LOGGER.info User.count
App::LOGGER.info User.create(login: 'POPO').inspect
App::LOGGER.info User.count

App::LOGGER.info '<<<<<<<<<<<<<<<<<<<<<<<'
