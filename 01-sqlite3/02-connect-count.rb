#!/usr/bin/env ruby

require_relative 'config/app'

db = App.connection

count = db.get_first_value('SELECT COUNT(*) FROM users;')
puts "Users: #{count}"
