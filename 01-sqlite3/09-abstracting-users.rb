#!/usr/bin/env ruby

require_relative 'config/app'

class User
  attr_accessor :id, :login, :password

  def initialize(attributes = {})
    @id       = attributes['id'      ]
    @login    = attributes['login'   ]
    @password = attributes['password']
  end

  def self.all(options = {})
    sql  = "SELECT ALL * FROM users"
    sql += " LIMIT #{options[:limit]}" if options[:limit]

    db = App.connection

    db.results_as_hash = true

    db.execute(sql).map { |columns| self.new columns }
  end
end

users = User.all(limit: 5)

users.each do |user|
  puts "id: #{user.id}, login: #{user.login}"
end
