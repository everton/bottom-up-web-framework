module Model
  module Creators
    def create(attrs = {})
      id = @connection.insert table_name, attrs
      find(id) # this dependence from Readers module is not ok...
    end
  end
end
