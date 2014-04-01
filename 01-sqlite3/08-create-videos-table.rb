#!/usr/bin/env ruby

require_relative 'config/app'

db = App.connection

create_sql = %q{
  CREATE TABLE IF NOT EXISTS videos (
    id INTEGER PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    filename VARCHAR(255),
    user_id INTEGER,
    FOREIGN KEY(user_id) REFERENCES users(id)
  );
}

db.execute create_sql

tables = db.execute 'SELECT tbl_name, sql FROM sqlite_master WHERE type="table";'

tables.each do |table|
  table_name = table[0]
  schema_sql = table[1]

  puts "Table: #{table_name}"
  puts "SQL:   #{schema_sql}"
end
