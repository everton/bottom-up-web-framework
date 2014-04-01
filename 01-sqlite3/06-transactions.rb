#!/usr/bin/env ruby

require 'benchmark'

require_relative 'config/app'
db = App.connection

puts db.get_first_value('SELECT COUNT(*) FROM users;')

begin
  db.transaction do |transaction|
    db.execute "INSERT INTO users (login) VALUES ('New User');"
    db.execute "INSERT INTO users (login) VALUES (NULL      ) ;"
  end
rescue => e
  puts 'An error has ocurred and the transaction was rolled back'
end

puts db.get_first_value('SELECT COUNT(*) FROM users;')
