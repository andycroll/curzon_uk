#!/usr/bin/env rake
require 'bundler/gem_tasks'

require 'rake/testtask'
require 'cinebase/vista/package_task'

Cinebase::Vista::PackageTask.new('curzon_uk.gemspec', root: __dir__)

Rake::TestTask.new do |t|
  t.libs << 'lib/curzon_uk'
  t.test_files = FileList[
    'test/lib/curzon_uk/*_test.rb',
    'test/lib/curzon_uk/internal/*_test.rb',
    'test/lib/curzon_uk/internal/parser/api/*_test.rb'
  ]
  t.verbose = true
end

Rake::TestTask.new do |t|
  t.libs << 'lib/curzon_uk'
  t.name = :live
  t.test_files = FileList[
    'test/live/*_test.rb'
  ]
  t.verbose = true
end

# http://erniemiller.org/2014/02/05/7-lines-every-gems-rakefile-should-have/
desc 'run gem console'
task :console do
  require 'irb'
  require 'irb/completion'
  require 'curzon_uk'
  ARGV.clear
  IRB.start
end

task default: :test
