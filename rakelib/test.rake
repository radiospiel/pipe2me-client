task :test => "test:debug"
namespace :test do
  # run a debug test against pipe2.dev. This is the default test scenario.
  #
  # pipe2.dev, which should  point to 127.0.0.1, should run a development 
  # version of the pipe2me server package.
  task :debug do
    require "simple/ui"
    require_relative "../lib/pipe2me/ext/sys"
    unless Pipe2me::Sys.sys :bash, "-c", "curl -O /dev/null http://pipe2.dev:8080 2> /dev/null"
      UI.error "Could not find test pipe2me test server on http://pipe2.dev:8080"
      exit 1
    end

    FileUtils.mkdir_p "tmp"
    system "TEST_ENV=debug sbin/roundup test/*-test.sh"
  end

  # run a release test - a test against test.pipe2.me. Please run this
  # test before releasing a new version.
  task :release do
    FileUtils.mkdir_p "tmp"
    system "TEST_ENV=release sbin/roundup test/*-test.sh"
  end
end
