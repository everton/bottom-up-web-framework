#!/usr/bin/env ruby

require_relative 'extenssions/model'

class User < Model
end

class Video < Model
  belongs_to :user
end

users = User.all(limit: 5)

Video.delete_all

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
