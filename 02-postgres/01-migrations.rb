#!/usr/bin/env ruby

require_relative 'extenssions/migration'

class CreateUsers < Migration
  def self.change
    create_table 'users' do |table|
      table.string :login, constraints: 'NOT NULL'
      table.string :password
    end
  end
end

class CreateVideos < Migration
  def self.change
    create_table 'videos' do |table|
      table.integer :user_id, references: :users
      table.string :title, constraints: 'NOT NULL'
      table.string :filename

    end
  end
end

CreateUsers.run!
CreateVideos.run!

class User < Model
end

class Video < Model
end

puts "Users  table fields: #{ User.column_names.inspect}"
puts "Video  table fields: #{Video.column_names.inspect}"
