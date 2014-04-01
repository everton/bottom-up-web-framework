require 'sqlite3'

class App
  DATABASE = 'db/development.sql'

  def self.connection
    SQLite3::Database.new DATABASE
  end
end
