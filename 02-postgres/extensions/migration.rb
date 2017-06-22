require_relative 'model'

class Migration
  class << self
    def run!
      create_versions_table_if_not_exist!

      return if version_already_migrated?

      Model.connection.transaction do
        change if respond_to? :change

        register_version_as_migrated!
      end
    end

    def create_table(table_name, &block)
      table = Table.new(table_name)

      yield(table) if block_given?

      table.create!
    end

    private
    def create_versions_table_if_not_exist!
      query = "CREATE TABLE IF NOT EXISTS schema_migrations (" +
        " version VARCHAR(255) NOT NULL" +
        ");"

      # TODO: unify SQLite3#execute and PG#exec + PG#exec_params + PG#exec_prepared
      Model.connection.exec query
    end

    def version_already_migrated?
      # TODO: should be some Driver#count or something like this
      query = "SELECT DISTINCT COUNT(*) AS count " +
        " FROM schema_migrations " +
        " WHERE version='#{self.name}';"

      count = Model.connection.exec(query)[0]['count'].to_i

      count.nonzero?
    end

    def register_version_as_migrated!
      # TODO: should be some Driver#insert or something like this
      query = "INSERT INTO schema_migrations" +
        " ( version ) VALUES ( '#{self.name}' );"

      Model.connection.exec query
    end
  end

  # TODO: Table definition should be on Driver
  class Table
    attr_accessor :name, :fields

    def initialize(name)
      @name = name
      @fields = ["id INTEGER PRIMARY KEY DEFAULT nextval('#{sequence}')"]
    end

    def string(name, options = {})
      fields << "#{name} VARCHAR(255) #{options[:constraints]}"
    end

    def integer(name, options = {})
      refs = options[:references]

      fields << "#{name} INTEGER #{options[:constraints]}"
      fields << "FOREIGN KEY(#{name}) REFERENCES #{refs}(id)" if refs
    end

    def create!
      puts "Creating table #{name}"

      puts sequence_sql
      Model.connection.exec sequence_sql

      puts create_sql
      Model.connection.exec create_sql
    end

    def sequence_sql
      "CREATE SEQUENCE #{sequence};"
    end

    def create_sql
      fields_sql = fields.join(', ')

      "CREATE TABLE IF NOT EXISTS #{name} ( #{fields_sql} );"
    end

    def sequence
      "#{name}_id_seq"
    end
  end
end
