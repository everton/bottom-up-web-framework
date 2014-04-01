require 'sqlite3'

class App
  DATABASE = File.join(File.dirname(__FILE__), '..', 'db', 'development.sql')

  def self.connection
    SQLite3::Database.new DATABASE
  end
end
