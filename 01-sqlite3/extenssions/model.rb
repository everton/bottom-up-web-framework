#!/usr/bin/env ruby

require_relative 'string'

require_relative '../config/app'

require_relative 'model/finders'
require_relative 'model/persistence'
require_relative 'model/relationships'

class Model
  extend Finders
  extend Relationships
  extend Persistence

  def self.connection
    @connection ||= App.connection
    @connection.results_as_hash = true

    return @connection
  end

  def self.table_name
    self.name.underscore.pluralize
  end

  def self.column_names
    connection.table_info(self.table_name).map do |column|
      column['name']
    end
  end

  def self.inherited(base)
    base.class_eval do
      attr_accessor *self.column_names
    end
  end

  def connection
    self.class.connection
  end

  def initialize(attributes = {})
    self.class.column_names.each do |column|
      column = column.to_sym if attributes.has_key? column.to_sym
      self.send "#{column}=", attributes[column]
    end
  end
end
