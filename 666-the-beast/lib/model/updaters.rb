module Model
  module Updaters
    def self.extended(base)
      base.include InstanceMethods
    end

    module InstanceMethods
      def update(attrs = {})
        attrs.each do |attr, value|
          send "#{attr}=", value
        end

        save_on_update
      end

      private
      def save_on_update
        connection.update table_name, self.id, self.attributes
        return self
      end
    end
  end
end
