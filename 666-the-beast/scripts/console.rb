#!/usr/bin/env ruby

# Thanks:
#  http://jameskilton.com/2009/04/02/embedding-irb-into-your-ruby-application

require 'irb'

module IRB # :nodoc:
  def self.start_session(binding)
    IRB.setup(nil)

    workspace = WorkSpace.new(binding)
    irb       = Irb.new(workspace)

    @CONF[:MAIN_CONTEXT] = irb.context

    catch(:IRB_EXIT) do
      irb.eval_input
    end
  end
end

require_relative File.expand_path '../../config/app.rb', __FILE__

puts 'Starting app..'
App.boot!

puts 'Starting console...'
IRB.start_session binding
