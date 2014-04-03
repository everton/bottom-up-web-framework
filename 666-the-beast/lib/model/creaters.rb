module Model
  module Creaters
    def self.extended(base)
      base.include InstanceMethods
    end

    def create(attrs = {})
      new(attrs).save
    end

    module InstanceMethods
      private
      def save_on_insert
        self.id = connection.insert table_name, self.attributes
        return self
      end
    end
  end
end
