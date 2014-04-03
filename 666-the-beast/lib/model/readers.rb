module Model
  module Readers
    def all(options = {})
      @connection.select_all(table_name, options).map do |columns|
        self.new columns
      end
    end

    def count(options = {})
      options[:select] ||= 'COUNT(*) AS count'

      @connection.select_all(table_name, options)
        .first['count']
        .to_i
    end

    def first(options = {})
      all(limit: 1, where: options[:where]).first
    end

    def find(id)
      first(where: { id: id }) or raise "ModelNotFound id: #{id}"
    end
  end
end
