task :test => "test:debug"
namespace :test do
  # run a debug test - a test against pipe2.dev. This is the default
  # test scenario.
  task :debug do
    FileUtils.mkdir_p "tmp"
    system "TEST_ENV=debug roundup test/*-test.sh"
  end

  # run a release test - a test against test.pipe2.me. Please run this
  # test before releasing a new version.
  task :release do
    FileUtils.mkdir_p "tmp"
    system "TEST_ENV=release roundup test/*-test.sh"
  end
end
