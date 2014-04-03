module Finders
  def all(options = {})
    options[:where] ||= {}

    sql  = "SELECT ALL * FROM #{self.table_name} "
    sql += where options[:where]
    sql += limit options[:limit]

    connection.execute(sql, options[:where]).map do |columns|
      self.new columns
    end
  end

  def first(options = {})
    all(limit: 1, where: options[:where]).first
  end

  private
  def where(conditions = {})
    return '' if conditions.empty?

    # ['k1=:k1', 'k2=:k2', ...]
    keys = conditions.keys.map {|k| "#{k}=:#{k}" }

    " WHERE #{keys.join ' AND '} "
  end

  def limit(limit = nil)
    return '' unless limit

    " LIMIT #{limit} "
  end
end
