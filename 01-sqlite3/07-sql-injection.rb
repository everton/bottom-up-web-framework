#!/usr/bin/env ruby

require 'benchmark'

require_relative 'config/app'
db = App.connection

ingenuous_param = "user1"
malicious_param = "' OR 1=1 --"

puts db.execute("SELECT * FROM users WHERE login='#{ingenuous_param}';").inspect

puts db.execute("SELECT * FROM users WHERE login='#{malicious_param}';").inspect
