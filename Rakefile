require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec

task :console do
  require 'irb'
  require 'irb/completion'
  require './lib/slither'
  ARGV.clear
  IRB.start
end