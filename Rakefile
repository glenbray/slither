require 'rake'

# PROJ.name = 'slither'
# PROJ.authors = 'Ryan Wood'
# PROJ.email = 'ryan.wood@gmail.com'
# PROJ.url = 'http://github.com/ryanwood/slither'
# PROJ.version = '0.99.3'
# PROJ.exclude = %w(\.git .gitignore ^tasks \.eprj ^pkg)
# PROJ.readme_file = 'README.rdoc'

# #PROJ.rubyforge.name = 'codeforpeople'

# PROJ.rdoc.exclude << '^data'
# PROJ.notes.exclude = %w(^README\.rdoc$ ^data ^pkg)

# PROJ.spec.opts << '--color'


require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec