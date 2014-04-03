#!/usr/bin/env ruby

require_relative File.expand_path '../../config/app.rb', __FILE__

App.boot!

Dir[ App.root.join 'db/migrations/*.rb' ].each do |file|
  require file

  migration = File.basename(file, '.rb').camelize.constantize

  migration.run!
end
