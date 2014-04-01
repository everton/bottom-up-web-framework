#!/usr/bin/env ruby

require 'sqlite3'

db = SQLite3::Database.new '01-sqlite3/db/development.sql'

db.execute %q{
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    login VARCHAR(255) NOT NULL,
    password VARCHAR(255)
  );
}
