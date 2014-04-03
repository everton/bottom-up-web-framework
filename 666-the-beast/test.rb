#!/usr/bin/env ruby

require_relative 'config/app'

App::LOGGER.info '>>>>>>>>>>>>>>>>>>>>>>>'

App::LOGGER.info App.boot!

App::LOGGER.info '-----------------------'

Video.delete_all
 User.delete_all

10.times do |n|
  User.create login: "user#{n}", password: 'secret'
end

users = User.all(limit: 5)

App::LOGGER.info "All videos: #{Video.all.inspect}"

users.each do |user|
  Video.create title: "New video from user #{user.id}",
    user_id: user.id
end

video = Video.first

App::LOGGER.info "Video: '#{video.id} - #{video.title}'" +
  " (User login: #{video.user.login})"

video.title = "New Title"
App::LOGGER.info "Saved: #{video.save}"

App::LOGGER.info "New video title: #{video.title}"

video.update title: "Newest Title"
App::LOGGER.info "Saved: #{video}"
App::LOGGER.info "New video title: #{video.title}"

App::LOGGER.info '<<<<<<<<<<<<<<<<<<<<<<<'
