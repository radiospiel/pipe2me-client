task :default => :test

task :test => "test:debug"
namespace :test do
  # run a debug test - a test against pipe2.dev. This is the default
  # test scenario.
  task :debug do
    system "TEST_ENV=debug roundup test/*-test.sh"
  end

  # run a release test - a test against test.pipe2.me. Please run this
  # test before releasing a new version.
  task :release do
    system "TEST_ENV=release roundup test/*-test.sh"
  end
end

task :doc do
  system "ronn doc/*.ronn"
end

task :install do
  system "sudo cp doc/pipe2me.1 /usr/local/share/man/man1"
end

# Add "rake release and rake install"
require "bundler/setup"

Bundler::GemHelper.install_tasks
