module Persistence
  def delete_all
    connection.execute "DELETE FROM #{table_name};"
  end

  def create(attrs = {})
    new(attrs).save!
  end

  def self.extended(base)
    base.class_eval do
      def save!
        if self.id
          save_on_update!
        else
          save_on_insert!
        end

        return self
      end

      private
      def save_on_update!
        fields, values = fields_and_values
        placeholders   = fields.map { |column| "#{column}=?"  }

        query = "UPDATE #{self.class.table_name} " +
          " SET #{placeholders.join(', ') } " +
          " WHERE id=#{self.id};"

        connection.execute query, values
      end

      def save_on_insert!
        fields, values = fields_and_values
        placeholders   = values.map{ '?' }

        query = "INSERT INTO #{self.class.table_name}" +
          " ( #{fields.join ', '} )" +
          " VALUES ( #{placeholders.join ', '} );"

        connection.execute query, values

        self.id = connection.last_insert_row_id
      end

      def fields_and_values
        fields = self.class.column_names - ['id']
        values = fields.map { |column| send column }

        [fields, values]
      end
    end
  end
end
