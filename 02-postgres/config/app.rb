require 'pg'
require 'pathname'

class App
  DATABASE_CONFIG = {
    dbname: 'bottom_up_web_framework_development',
    hostaddr: '127.0.0.1',
    user: 'postgres'
  }

  class << self
    def connection
      tries = 0

      begin
        PG.connect DATABASE_CONFIG
      rescue PG::ConnectionBad => e
        raise e if tries > 0

        tries += 1

        general_config = DATABASE_CONFIG.dup
        database_name  = general_config.delete :dbname

        puts e.message, "Trying to create database #{database_name}..."

        general_connection = PG.connect general_config
        general_connection.exec "CREATE DATABASE #{database_name};"

        puts "Trying to reconnect..."

        retry
      end
    end

    def root
      Pathname.new File.realpath(File.join(File.dirname(__FILE__), '..'))
    end

    def boot!
      require root.join 'extensions', 'model.rb'
      require root.join 'extensions', 'migration.rb'

      require_models
    end

    private
    def require_models
      Dir[ root.join('app', 'models', '*.rb') ].each do |model_file|
        require model_file
      end
    end
  end
end
