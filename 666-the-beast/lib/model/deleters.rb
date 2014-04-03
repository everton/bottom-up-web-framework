module Model
  module Deleters
    def delete_all
      @connection.delete table_name
    end
  end
end
