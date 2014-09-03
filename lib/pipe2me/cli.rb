require "thor"
require_relative "which"

class Pipe2me::CLI < Thor
  class_option :dir,                        :type => :string
  class_option :verbose,  :aliases => "-v", :type => :boolean
  class_option :quiet,    :aliases => "-q", :type => :boolean
  class_option :silent,                     :type => :boolean
  class_option :insecure, :aliases => "-k", :type => :boolean

  private

  def handle_global_options
    UI.verbosity = 2
    if options[:verbose]
      UI.verbosity = 3
    elsif options[:quiet]
      UI.verbosity = 1
    elsif options[:silent]
      UI.verbosity = -1
    end

    if options[:dir]
      Dir.chdir options[:dir]
      UI.info "Changed into", options[:dir]
    end

    if options[:insecure]
      Pipe2me::HTTP.enable_insecure_mode
    end
  end

  public

  def self.exit_on_failure?; true; end

  desc "version", "print version information"
  def version
    handle_global_options

    puts Pipe2me::VERSION
  end

  desc "setup", "fetch a new tunnel setup"
  option :server,     :aliases => "-s", :default => "http://test.pipe2.me"
  option :token,      :required => true                       # "tunnel token"
  option :protocols,  :default => "https"                     # "protocol names, e.g. 'http,https,imap'"
  option :ports,      :type => :string                        # "local ports, one per protocol"
  def setup
    handle_global_options

    Pipe2me.server = options[:server]
    server_info = Pipe2me::Tunnel.setup options

    update
    puts server_info[:fqdn]
  end

  desc "env", "show tunnel configuration"
  def env(*args)
    handle_global_options

    puts File.read("pipe2me.local.inc")
    puts File.read("pipe2me.info.inc")
  end

  desc "verify", "Verify the tunnel"
  def verify
    handle_global_options

    Pipe2me::Tunnel.verify
  end

  desc "update", "Updates configuration"
  def update
    handle_global_options

    Pipe2me::Tunnel.update
  end

  desc "check", "check online status"
  def check
    handle_global_options

    Pipe2me::Tunnel.check
  end

  desc "start", "start tunnels"
  def start
    handle_global_options

    Pipe2me::Tunnel.tunnels.each do |tunnel|
      UI.info "Setting up", tunnel
    end

    cmd = Pipe2me::Tunnel.command
    UI.info cmd
    Kernel.exec cmd
  end

  desc "clear", "clear configuration"
  def clear
    handle_global_options

    UI.error "This will remove the configuration in #{Dir.getwd}. Continue? (^C to cancel)"
    STDIN.gets

    Pipe2me::Tunnel.clear
  end
end
