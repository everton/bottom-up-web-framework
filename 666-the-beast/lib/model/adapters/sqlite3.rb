require 'sqlite3'

module Model
  module Adapters
    class SQLite3
      def self.connect(config)
        db_file = App.root.join config['database']

        App::LOGGER.info "Connecting to database: #{db_file}"

        db_conn = ::SQLite3::Database.new db_file.to_s

        # By default columns are an Array and you can't access
        # their column through column names
        db_conn.results_as_hash = true

        self.new db_conn
      end

      def initialize(connection)
        @connection = connection
      end

      def columns_of_table(table_name)
        @connection.table_info(table_name).map do |infos|
          infos['name']
        end
      end

      def select_all(table_name, options = {})
        query = select_query_from_options(table_name, options)

        App::LOGGER.debug query

        @connection.execute(query, options[:where])
      end

      def insert(table_name, fields_and_values = {})
        fields = fields_and_values.keys
        values = fields_and_values.values

        # Someting like: INTO ( ?, ?, ? )...
        placeholders   = values.each_with_index.map{ '?' }

        query = "INSERT INTO #{table_name}" +
          " ( #{fields.join ', '} )" +
          " VALUES ( #{placeholders.join ', '} )"

        App::LOGGER.debug "#{query} (#{values})"

        @connection.execute query, values

        last_id_select = 'last_insert_rowid() AS id'

        return self
          .select_all(table_name, select: last_id_select)
          .first['id']
      end

      def transaction(&block)
        @connection.transaction(&block)
      end

      # DDL
      def create_table(table_name, options = {}, &block)
        table = Table.new(table_name, options)

        yield(table) if block_given?

        create_sql = table.create_sql

        App::LOGGER.info "Creating table #{table_name}"
        App::LOGGER.debug create_sql

        @connection.execute create_sql
      end

      def delete(table_name, options = {})
        options[:where] ||= {}

        query = "DELETE FROM #{table_name} #{where(options[:where])}"

        App::LOGGER.debug query

        @connection.execute(query, options[:where])
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

        # ['k1=:k1', 'k2=:k2', ...]
        keys = conditions.keys.map {|k, _| "#{k}=:#{k}" }

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
          @fields << 'id INTEGER PRIMARY KEY' unless options[:no_id]
        end

        def string(name, options = {})
          fields << "#{name} VARCHAR(255) #{options[:constraints]}"
        end

        def integer(name, options = {})
          refs = options[:references]

          fields << "#{name} INTEGER #{options[:constraints]}"
          fks    << "FOREIGN KEY(#{name}) REFERENCES #{refs}(id)" if refs
        end

        def create_sql
          fields_sql = (fields + fks).join(', ')

          "CREATE TABLE IF NOT EXISTS #{name} ( #{fields_sql} );"
        end
      end
    end
  end
end
