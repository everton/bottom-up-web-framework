module Model
  module Relationships
    def belongs_to(other)
      define_method other do
        # 'admin_user' -> 'AdminUser' -> AdminUser
        model_class = other.to_s.camelize.constantize

        model_class.first where: {
          id: self.send("#{other}_id")
        }
      end
    end
  end
end
