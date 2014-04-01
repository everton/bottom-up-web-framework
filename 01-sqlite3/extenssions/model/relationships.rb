module Relationships
  def belongs_to(other)
    define_method other do
      # 'user' -> 'User' -> User
      model_class = other.to_s.capitalize.constantize

      model_class.first where: {
        id: self.send("#{other}_id")
      }
    end
  end
end
