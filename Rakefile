require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :default => [:test]

task :clean do
  `rm -rf 01-sqlite3/db/*.sql`

  `find ./ -name \\*~ -delete`
end

task :test => [:clean]

task :stats => :clean do
  [ '01-sqlite3', '02-postgres'].each do |examples_folder|
    lloc = `find #{examples_folder} -name \\*.rb -exec cat {} \\; |sed /^\w*$/d |wc -l`.to_i
    puts "Code LOC %15s: %4d" % [examples_folder, lloc]
  end
end
