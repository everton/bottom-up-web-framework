#!/usr/bin/env ruby

require 'benchmark'

require_relative 'config/app'
db = App.connection

query = "SELECT * FROM users WHERE login=:login LIMIT 1;";

prepared_statement = db.prepare query

Benchmark.bm do |query_benchmark|
  query_benchmark.report do
    1000.times do
      db.execute query, login: "user#{rand(100)}"
    end
  end

  query_benchmark.report do
    1000.times do
      prepared_statement.bind_param :login, "user#{rand(100)}"

      prepared_statement.execute
    end
  end
end
