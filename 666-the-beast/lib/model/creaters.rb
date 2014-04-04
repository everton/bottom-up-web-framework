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
        new_attrs = self.attributes.reject {|k, _| k == :id }

        self.id   = connection.insert table_name, new_attrs

        return self
      end
    end
  end
end
