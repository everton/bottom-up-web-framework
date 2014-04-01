#!/usr/bin/env ruby

require 'erb'

x = rand(10)

template = ERB.new 'X + 2 = <%= 2 + x %>. What is the X?'

puts template.run(binding)
