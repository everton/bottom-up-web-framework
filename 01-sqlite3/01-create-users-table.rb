#!/usr/bin/env ruby

require 'sqlite3'

db = SQLite3::Database.new '01-sqlite3/db/development.sql'

create_sql = %q{
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    login VARCHAR(255) NOT NULL,
    password VARCHAR(255)
  );
}

count  = db.execute create_sql

tables = db.execute 'SELECT tbl_name, sql FROM sqlite_master WHERE type="table";'

tables.each do |table|
  table_name = table[0]
  schema_sql = table[1]

  puts "Table: #{table_name}"
  puts "SQL:   #{schema_sql}"
end
