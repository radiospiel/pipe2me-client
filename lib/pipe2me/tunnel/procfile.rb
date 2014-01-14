module Pipe2me::Tunnel::Procfile
  PROCFILE    = Pipe2me::Tunnel::PROCFILE
  SSH_PUBKEY  = Pipe2me::Tunnel::SSH_PUBKEY
  SSH_PRIVKEY = Pipe2me::Tunnel::SSH_PRIVKEY

  def procfile(mode = "tunnels")
    entries = commands(mode).map do |name, cmd|
      "#{name}: #{cmd}"
    end

    path = "#{PROCFILE}.#{mode}"
    File.atomic_write path, entries.compact.join("\n")
    path
  end

  # returns an array of [ protocol, remote_port, local_port ] entries
  def tunnels
    @tunnels ||= begin
      urls, local_ports = config.urls, config.local_ports

      urls.zip(local_ports).map do |url, local_port|
        uri = URI.parse(url)
        [ uri.scheme, uri.port, local_port || uri.port ]
      end
    end
  end

  # return an arry [ [name, command ], [name, command ], .. ]
  def commands(mode = "tunnel")
    tunnel_uri = URI.parse config.tunnel

    commands = []

    # add commands for port tunnels
    tunnels.each do |protocol, remote_port, local_port|
      next unless cmd = port_tunnel_command(tunnel_uri, protocol, remote_port, local_port)
      commands << [ "#{protocol}_#{remote_port}", cmd ]
    end

    # add commands for echo servers
    if mode == "echo"
      tunnels.each do |protocol, remote_port, local_port|
        next unless cmd = echo_server_command(protocol, local_port)
        commands << [ "echo_#{remote_port}", cmd ]
      end
    end

    commands
  end

  def port_tunnel_command(tunnel_uri, protocol, remote_port, local_port)
    autossh = `which autossh`.chomp

    cmd = <<-SHELL
      env AUTOSSH_GATETIME=0                                # comments work here..
      #{autossh}
      -M 0
      #{tunnel_uri.user}@#{tunnel_uri.host}
      -p #{tunnel_uri.port}
      -R 0.0.0.0:#{remote_port}:localhost:#{local_port}
      -i #{SSH_PRIVKEY}
      -o StrictHostKeyChecking=no
      -o UserKnownHostsFile=pipe2me.known_hosts
      -N
    SHELL

    # remove comments and newlines from commands
    cmd.gsub(/( *#.*|\s+)/, " ").gsub(/(^ )|( $)/, "")
  end

  def echo_server_command(protocol, port)
    binary = File.dirname(__FILE__) + "/echo/#{protocol}"
    return unless File.executable?(binary)

    UI.info "Starting #{protocol} echo server on port #{port}"
    "env PORT=#{port} #{binary}"
  end
end
