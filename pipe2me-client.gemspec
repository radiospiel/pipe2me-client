$:.unshift File.expand_path("../lib", __FILE__)
require "pipe2me/version"

class Gem::Specification
  class GemfileEvaluator
    def initialize(scope)
      @scope = scope
    end
    
    def load_dependencies(path)
      instance_eval File.read(path) 
    end
    
    def source(*args); end
    def group(*args); end

    def gem(name, options = {})
      @scope.add_dependency(name)
    end
  end
  
  def load_dependencies(file)
    GemfileEvaluator.new(self).load_dependencies(file)
  end
end

Gem::Specification.new do |gem|
  gem.name     = "pipe2me-client"
  gem.version  = Pipe2me::VERSION
  
  gem.executables = %w[ pipe2me ]
  
  gem.author   = "radiospiel"
  gem.email    = "contact@kinko.me"
  gem.homepage = "https://github.com/kinko/pipe2me-client"
  gem.summary  = Pipe2me::BANNER

  gem.description = gem.summary
  gem.load_dependencies "Gemfile"

  gem.files = Dir["**/*"].select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }
end
