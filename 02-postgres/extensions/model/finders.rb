# TODO: queries are specific for each Driver
module Finders
  def all(options = {})
    options[:where] ||= {}

    sql  = "SELECT ALL * FROM #{self.table_name} "
    sql += where options[:where]
    sql += limit options[:limit]

    connection.exec_params(sql, options[:where].values).map do |columns|
      self.new columns
    end
  end

  def first(options = {})
    all(limit: 1, where: options[:where]).first
  end

  private
  def where(conditions = {})
    return '' if conditions.empty?

    # ['k1=$1', 'k2=$2', ...]
    keys = conditions.keys.each_with_index.map {|k, i| "#{k}=$#{ i + 1}" }

    " WHERE #{keys.join ' AND '} "
  end

  def limit(limit = nil)
    return '' unless limit

    " LIMIT #{limit} "
  end
end
