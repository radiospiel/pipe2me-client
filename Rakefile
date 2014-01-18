task :default => :test

task :doc do
  system "ronn doc/*.ronn"
end

task :install do
  system "sudo cp doc/pipe2me.1 /usr/local/share/man/man1"
end

