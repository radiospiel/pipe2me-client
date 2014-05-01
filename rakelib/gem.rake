# Add "rake release and rake install"
require "bundler/setup"
Bundler::GemHelper.install_tasks

task :release => :changelog

# update CHANGELOG file
task :changelog do
  require "simple/ui"
  FileUtils.cp "CHANGELOG.md", "CHANGELOG.old.md"
  
  version_tags = `git tag -l 'v[0-9]*'`.split("\n")
  version_tags = version_tags.sort_by do |tag|
    tag.split(/\D+/).reject(&:empty?).map(&:to_i)
  end
  last_version = version_tags.last

  current_version = `bin/pipe2me version`.chomp
  UI.success "Changes from #{last_version} .. #{current_version}:"

  changes = `git log  --format=format:'- %s [%an]' #{last_version}..HEAD`
  UI.warn "\n#{changes}\n"

  system "git reset CHANGELOG.md > /dev/null"
  system "git checkout CHANGELOG.md"

  old_changelog = File.read "CHANGELOG.md"
  File.open "CHANGELOG.md", "w" do |io|
    io.write "# v#{current_version}: #{Time.now.strftime "%c"}\n\n"
    io.write changes
    io.write "\n\n"
    io.write old_changelog
  end
  
  system "git commit -m 'Updates CHANGELOG.md' CHANGELOG.md"
end
