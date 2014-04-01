#!/usr/bin/env ruby

require 'benchmark'

require_relative 'config/app'
db = App.connection

count = db.get_first_value('SELECT COUNT(*) FROM users;')
puts "There is #{count} users on database now"

begin
  db.transaction do |transaction|
    db.execute "INSERT INTO users (login) VALUES ('New User');"
    db.execute "INSERT INTO users (login) VALUES (NULL      ) ;"
  end
rescue => e
  puts 'An error has ocurred and the transaction was rolled back'
end

count = db.get_first_value('SELECT COUNT(*) FROM users;')
puts "There is #{count} users on database now"
