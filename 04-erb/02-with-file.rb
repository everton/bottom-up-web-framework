#!/usr/bin/env ruby

require 'erb'

@title = 'Sample page created using ERB'

def l337(text)
  text.tr 'aeiost', '431057'
end

filepath = File.join File.dirname(__FILE__),
  'template-example.html.erb'

template = ERB.new File.read(filepath)

puts template.result(binding)
