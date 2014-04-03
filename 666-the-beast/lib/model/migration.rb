module Model
  class Migration
    class << self
      def connection
        Model::Base.connection
      end

      def run!
        create_versions_table_if_not_exist!

        return if version_already_migrated?

        connection.transaction do
          change if respond_to? :change

          register_version_as_migrated!
        end
      end

      def create_table(table_name, &block)
        connection.create_table(table_name, &block)
      end

      private
      def create_versions_table_if_not_exist!
        connection.create_table('schema_migrations', no_id: true) do |t|
          t.string :version, constraints: 'NOT NULL'
        end
      end

      def version_already_migrated?
        options = {
          select: 'DISTINCT COUNT(*) AS count',
          where: { version: self.name }
        }

        count = connection
          .select_all('schema_migrations', options)
          .first['count']
          .to_i

        count.nonzero?
      end

      def register_version_as_migrated!
        connection.insert 'schema_migrations', version: self.name
      end
    end
  end
end
