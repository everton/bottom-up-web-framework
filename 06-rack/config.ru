# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/app.rb',  __FILE__)
run App.new
