#!/usr/bin/env ruby

require 'ostruct'

require_relative 'extensions/controller'

class User
  def self.all
    [
     OpenStruct.new(name: 'John',   id: 4),
     OpenStruct.new(name: 'Paul',   id: 3),
     OpenStruct.new(name: 'George', id: 2),
     OpenStruct.new(name: 'Ringo',  id: 1)
    ]
  end

  def self.find(id)
    all.find { |u| u.id == id.to_i }
  end
end

class UsersController < Controller
  def index
    @users = User.all
  end

  def show
    @user  = User.find params[:id]
  end

  private
  def user_path(user)
    "/users/#{user.id}"
  end
end

server = App.server

server.mount '/users/', UsersController

server.start
