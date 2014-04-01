class String
  def underscore
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

  def constantize
    Kernel.const_get self
  end

  def pluralize
    "#{self}s"
  end

  def singularize
    self[0..-1]
  end
end
