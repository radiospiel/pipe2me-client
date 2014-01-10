module Pipe2me::CLI
  banner "fetch a new tunnel setup"
  option :server, "Use pipe2.me server on that host", :default => "http://test.pipe2.me:8080"
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

  banner "Start tunnels"
  def start
    runner = File.dirname(__FILE__) + "/../../vendor/pipe2me-runner"
    Kernel.exec runner, Pipe2me::Tunnel::procfile
  end

  banner "Start tunnels in echo mode"
  def echo
    runner = File.dirname(__FILE__) + "/../../vendor/pipe2me-runner"
    Kernel.exec runner, Pipe2me::Tunnel::procfile("echo")
  end

  option :format, "Export configuration type", :default => "initscript"
  banner "export startup configuration"
  def export
    format = options[:format]
    procfile = Pipe2me::Tunnel::procfile

    target = "pipe2me.export.#{format}"
    whoami = `whoami`.chomp

    Pipe2me::Sys.sh! "foreman export #{format} -f #{procfile} --app pipe2me --user #{whoami} --log pipe2me.log #{target}"
    UI.success "Created #{target}"
  end
end
