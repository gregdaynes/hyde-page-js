require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
end

gemspec = eval(File.read("hyde-page-js.gemspec"))

desc "Run tests"
task default: :test

desc "Report current version to build"
task :next_build do
  puts "#{gemspec.full_name}.gem"
end

desc "Bulld and install gem"
task :build do
  system "gem build #{gemspec.name}.gemspec"
  system "gem install #{gemspec.name}-#{Hyde::Page::Js::VERSION}.gem"
end
