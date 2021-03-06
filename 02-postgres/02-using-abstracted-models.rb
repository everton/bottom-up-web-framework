#!/usr/bin/env ruby

require_relative 'config/app'

App.boot!

Video.delete_all
 User.delete_all

10.times do |n|
  User.create login: "user#{n}", password: 'secret'
end

users = User.all(limit: 5)

puts "All videos: #{Video.all.inspect}"

users.each do |user|
  Video.create title: "New video from user #{user.id}",
    user_id: user.id
end

video = Video.first

puts "Video: #{video.id} - #{video.title}" +
  " (User login: #{video.user.login})"

video.title = "New Title"
video.save!

puts "New video title: #{video.title}"
