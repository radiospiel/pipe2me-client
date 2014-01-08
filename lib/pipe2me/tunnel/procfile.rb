module Pipe2me::Tunnel::Procfile
  PROCFILE    = Pipe2me::Tunnel::PROCFILE
  SSH_PUBKEY  = Pipe2me::Tunnel::SSH_PUBKEY
  SSH_PRIVKEY = Pipe2me::Tunnel::SSH_PRIVKEY

  def procfile(mode = "tunnels")
    entries = commands
    path = "#{PROCFILE}.#{mode}"
    File.atomic_write path, entries.join("\n")
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

  def commands
    tunnel_uri = URI.parse config.tunnel

    tunnels.map do |protocol, remote_port, local_port|
      cmd = <<-SHELL
        env AUTOSSH_GATETIME=0                                # comments work here..
        autossh
        -M 0
        #{tunnel_uri.user}@#{tunnel_uri.host}
        -p #{tunnel_uri.port}
        -R 0.0.0.0:#{remote_port}:localhost:#{local_port}
        -i #{SSH_PRIVKEY}
        -o StrictHostKeyChecking=no
        -N
      SHELL

      "#{protocol}_#{remote_port}: #{uncomment cmd}"
    end
  end

  def uncomment(cmd)
    cmd.gsub(/( *#.*|\s+)/, " ").gsub(/(^ )|( $)/, "")
  end
end
