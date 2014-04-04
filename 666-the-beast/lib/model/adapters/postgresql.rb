require 'pg'

module Model
  module Adapters
    class PostgreSQL
      def self.connect(config)
        db_config = {
          hostaddr: config['host'    ],
          dbname:   config['database'],
          user:     config['username'],
          password: config['password']
        }

        connection_attempts = 0
        begin
          App::LOGGER.info "Connecting to: #{config['database']}"
          db_conn = PG.connect db_config

          self.new db_conn
        rescue PG::ConnectionBad => e
          raise e if connection_attempts > 0

          connection_attempts += 1

          general_config = db_config.dup
          database_name  = general_config.delete :dbname

          App::LOGGER.info e.message
          App::LOGGER.info "Trying to create database #{database_name}..."

          general_connection = PG.connect general_config
          general_connection.exec "CREATE DATABASE #{database_name};"

          App::LOGGER.info "Trying to reconnect..."
          retry
        end
      end

      def initialize(connection)
        @connection = connection
      end

      def columns_of_table(table_name)
        columns = select_all 'INFORMATION_SCHEMA.COLUMNS',
          select: 'column_name', where: { table_name: table_name }

        columns.map { |column| column['column_name'] }
      end

      def select_all(table_name, options = {})
        query = select_query_from_options(table_name, options)

        App::LOGGER.debug query

        @connection.exec_params(query, options[:where].values)
      end

      def insert(table_name, fields_and_values = {})
        fields = fields_and_values.keys
        values = fields_and_values.values

        # Someting like: INTO ( $1, $2, $3 )...
        placeholders = values.each_with_index.map{|_, i| "$#{i + 1}" }

        query = "INSERT INTO #{table_name}" +
          " ( #{fields.join ', '} )" +
          " VALUES ( #{placeholders.join ', '} )" +
          " RETURNING *;"

        App::LOGGER.debug "#{query} (#{values})"

        res = @connection.exec_params query, values

        return res[0]['id']
      end

      def update(table_name, id, fields_and_values = {})
        fields = fields_and_values.keys
        values = fields_and_values.values

        # Someting like: SET ( k1=$1, k2=$2, k3=$3 )...
        placeholders = fields.each_with_index.map do |k, i|
          "#{k}=$#{i + 1}"
        end

        query = "UPDATE #{table_name} " +
          " SET #{placeholders.join(', ') } " +
          " WHERE id=#{id};"

        App::LOGGER.debug query

        @connection.exec_params query, values
      end

      def delete(table_name, options = {})
        options[:where] ||= {}

        query = "DELETE FROM #{table_name} #{where(options[:where])}"

        App::LOGGER.debug query

        @connection.exec(query, options[:where].values)
      end

      def transaction(&block)
        @connection.transaction(&block)
      end

      # DDL
      def create_table(table_name, options = {}, &block)
        table = Table.new(table_name, options)

        yield(table) if block_given?

        unless options[:no_id]
          sequence_sql = table.sequence_sql

          App::LOGGER.info "Creating sequence #{table.sequence}"
          App::LOGGER.debug sequence_sql

          @connection.exec  sequence_sql
        end

        create_sql = table.create_sql

        App::LOGGER.info "Creating table #{table_name}"
        App::LOGGER.debug create_sql

        @connection.exec create_sql
      end

      private
      def select_query_from_options(table_name, options)
        options[:select] ||= 'ALL *'
        options[:where ] ||= {}

        sql  = []
        sql << "SELECT #{options[:select]}"
        sql << "FROM #{table_name}"
        sql << where(options[:where])
        sql << limit(options[:limit])

        sql.join(' ')
      end

      def where(conditions = {})
        return '' if conditions.empty?

        # ['k1=$1', 'k2=$2', ...]
        keys = conditions.keys.each_with_index.map do |k, i|
          "#{k}=$#{ i + 1}"
        end

        "WHERE #{keys.join ' AND '}"
      end

      def limit(limit = nil)
        return '' unless limit

        "LIMIT #{limit}"
      end

      class Table
        attr_accessor :name, :fields, :fks

        def initialize(name, options = {})
          @name   = name
          @fields = []
          @fks    = []

          @fields << "id INTEGER PRIMARY KEY DEFAULT nextval('#{sequence}')" unless options[:no_id]
        end

        def string(name, options = {})
          fields << "#{name} VARCHAR(255) #{options[:constraints]}"
        end

        def integer(name, options = {})
          refs = options[:references]

          fields << "#{name} INTEGER #{options[:constraints]}"
          fks    << "FOREIGN KEY(#{name}) REFERENCES #{refs}(id)" if refs
        end

        def sequence_sql
          "CREATE SEQUENCE #{sequence};"
        end

        def sequence
          "#{name}_id_seq"
        end

        def create_sql
          fields_sql = (fields + fks).join(', ')

          "CREATE TABLE IF NOT EXISTS #{name} ( #{fields_sql} );"
        end
      end
    end
  end
end
