module Persistence
  def delete_all
    connection.exec "DELETE FROM #{table_name};"
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

        # Someting like: INTO ( $1, $2, $3 )...
        placeholders   = fields.each_with_index.map{|k, i| "#{k}=$#{i + 1}" }

        query = "UPDATE #{self.class.table_name} " +
          " SET #{placeholders.join(', ') } " +
          " WHERE id=#{self.id};"

        connection.exec_params query, values
      end

      def save_on_insert!
        fields, values = fields_and_values

        # Someting like: INTO ( $1, $2, $3 )...
        placeholders   = values.each_with_index.map{|_, i| "$#{i + 1}" }

        query = "INSERT INTO #{self.class.table_name}" +
          " ( #{fields.join ', '} )" +
          " VALUES ( #{placeholders.join ', '} )" +
          " RETURNING *;"

        res = connection.exec_params query, values

        # self.id = connection.last_insert_row_id

        self.id = res[0]['id']
      end

      def fields_and_values
        fields = self.class.column_names - ['id']
        values = fields.map { |column| send column }

        [fields, values]
      end
    end
  end
end
