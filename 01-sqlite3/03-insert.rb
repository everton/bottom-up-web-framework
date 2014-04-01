#!/usr/bin/env ruby

require_relative 'config/app'

db = App.connection

100.times do |n|
  db.execute "INSERT INTO users (login, password) VALUES ('user#{n}', 'secret');"
end
