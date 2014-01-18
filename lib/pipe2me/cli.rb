require "thor"

class Pipe2me::CLI < Thor
  def self.exit_on_failure?; true; end

  desc "version", "print version information"
  def version
    puts Pipe2me::VERSION
  end

  desc "setup", "fetch a new tunnel setup"
  option :server, :default => "http://test.pipe2.me:8080"
  option :auth, :required => true                     # "auth token"
  option :protocols, :default => "https"              # "protocol names, e.g. 'http,https,imap'"
  option :ports                                       # "local ports, one per protocol"
  def setup
    Pipe2me::Config.server = options[:server]
    server_info = Pipe2me::Tunnel.setup options

    update
    puts server_info[:fqdn]
  end

  desc "env", "show tunnel configuration"
  def env(*args)
    puts File.read("pipe2me.local.inc")
    puts File.read("pipe2me.info.inc")
  end

  desc "verify", "Verify the tunnel"
  def verify
    Pipe2me::Tunnel.verify
  end

  desc "update", "Updates configuration"
  def update
    Pipe2me::Tunnel.update
  end
end
