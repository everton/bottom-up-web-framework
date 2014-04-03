require_relative 'creaters' # C
require_relative 'readers'  # R
require_relative 'updaters' # U
require_relative 'deleters' # D

require_relative 'relationships'

module Model
  class Base
    attr_accessor :attributes

    extend Model::Creaters
    extend Model::Readers
    extend Model::Updaters
    extend Model::Deleters

    extend Model::Relationships

    def self.connection
      @connection ||= establish_connection
    end

    def self.establish_connection(config = App.database_config)
      begin
        adapter_file = "adapters/#{config['adapter'].downcase}.rb"
        require_relative adapter_file
      rescue LoadError
        raise "UnknowAdapter: #{config['adapter']}"
      end

      adapter = const_get "Model::Adapters::#{config['adapter']}"
      @connection = adapter.connect config
    end

    def self.table_name
      self.name.underscore.pluralize
    end

    def self.column_names
      connection.columns_of_table table_name
    end

    def self.inherited(base)
      base.class_eval do
        attr_accessor *self.column_names
      end
    end

    def self.transaction(&block)
      connection.transaction(&block)
    end

    def connection
      self.class.connection
    end

    def table_name
      self.class.table_name
    end

    def new_record?
      id.nil?
    end

    def save
      if new_record?
        save_on_insert
      else
        save_on_update
      end
    end

    def initialize(attributes = {})
      self.attributes ||= {}

      self.class.column_names.each do |column|
        column = column.to_sym if attributes.has_key? column.to_sym

        value  = attributes[column]

        self.attributes[column] = value
        self.send "#{column}=",   value
      end
    end
  end
end
