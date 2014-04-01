#!/usr/bin/env ruby

require_relative 'config/irb_session'

x = rand(10)

puts "Before IRB: #{x}"

IRB.start_session binding

puts "After IRB: #{x}"
