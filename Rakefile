task :default => :test

task :test do
  Dir.chdir "test"
  system "roundup"
end

task :doc do
  system "ronn doc/*.ronn"
end
