module Pipe2me::CLI
  banner "fetch a new tunnel setup"
  option :server, "Use pipe2.me server on that host", :default => "http://pipe2.dev"
  option :auth, "pipe2.me auth token",  :type => String, :default => "pipe2-dev-token"
  option :protocols, "protocol names, e.g. 'http,https,imap'", :type => String, :default => "https"
  option :local_ports, "local ports, one per protocol", :type => String
  def setup
    Pipe2me::Config.server = options[:server]
    server_info = Pipe2me::Tunnel.setup options

    update
    puts server_info[:fqdn]
  end

  banner "show tunnel configuration"
  def env(*args)
    puts File.read("pipe2me.local.inc")
    puts File.read("pipe2me.info.inc")
  end

  banner "Updates configuration"
  def update
    Pipe2me::Tunnel.update
  end
end
