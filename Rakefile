require 'bundler/setup'
require 'rake/testtask'

require "sinatra/activerecord/rake"
require "./app"

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end

task default: :test
