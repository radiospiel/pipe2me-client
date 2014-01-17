require "thor"

class Pipe2me::CLI < Thor
  def self.exit_on_failure?; true; end

  desc "setup", "fetch a new tunnel setup"
  option :server, :default => "http://test.pipe2.me:8080"
  option :auth, :required => true                     # "auth token"
  option :protocols, :default => "https"                    # "protocol names, e.g. 'http,https,imap'"
  option :local_ports                                       # "local ports, one per protocol"
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

  desc "update", "Updates configuration"
  def update
    Pipe2me::Tunnel.update
  end

  desc "start", "Start tunnels"
  def start
    procfile = "pipe2me.procfile"

    commands = Pipe2me::Tunnel.tunnel_commands
    write_procfile procfile, commands

    Kernel.exec "foreman start -f #{procfile}"
  end

  desc "echo", "Start tunnels in echo mode"
  def echo
    procfile = "pipe2me.procfile.echo"

    commands = Pipe2me::Tunnel.tunnel_commands
    commands += Pipe2me::Tunnel.echo_commands
    write_procfile procfile, commands

    Kernel.exec "foreman start -f #{procfile}"
  end

  private

  def write_procfile(path, cmds)
    File.atomic_write path do |io|
      cmds.each do |name, cmd|
        io.write "#{name}: #{cmd}\n"
      end
    end
  end
end
