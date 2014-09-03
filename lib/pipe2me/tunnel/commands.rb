module Pipe2me::Tunnel::Commands
  extend self

  T = Pipe2me::Tunnel

  # returns an array of [ protocol, remote_port, local_port ] entries
  def tunnels
    @tunnels ||= begin
      urls, ports = config.urls, config.ports.to_s.split(",")

      urls.zip(ports).map do |url, local_port|
        uri = URI.parse(url)
        [ uri.scheme, uri.port, local_port || uri.port ]
      end
    end
  end

  # return an arry [ [name, command ], [name, command ], .. ]
  def tunnel_command
    tunnel_uri = URI.parse config.tunnel

    port_mappings = tunnels.map do |protocol, remote_port, local_port|
      [ remote_port, local_port ]
    end

    cmd = port_tunnel_command(tunnel_uri, port_mappings)
    [ "tunnel", cmd ]
  end

  private

  def port_tunnel_command(tunnel_uri, port_mappings)
    port_mappings = port_mappings.map do |remote_port, local_port|
      "-R 0.0.0.0:#{remote_port}:localhost:#{local_port}"
    end.join(" ")

    cmd = <<-SHELL
      env AUTOSSH_GATETIME=0                                # comments work here..
      #{Which::AUTOSSH}
      -M 0
      -F #{T::SSH_CONFIG}
      #{tunnel_uri.user}@#{tunnel_uri.host}
      -p #{tunnel_uri.port}
      #{port_mappings}
      -i #{T::SSH_PRIVKEY}
      -o StrictHostKeyChecking=no
      -o UserKnownHostsFile=pipe2me.known_hosts
      -o PasswordAuthentication=no
      -o ExitOnForwardFailure=yes 
      -N
    SHELL

    # remove comments and newlines from commands
    cmd.gsub(/( *#.*|\s+)/, " ").gsub(/(^ )|( $)/, "")
  end
end
