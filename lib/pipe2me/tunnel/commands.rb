module Pipe2me::Tunnel::Commands
  extend self

  T = Pipe2me::Tunnel

  def tunnel_uri
    URI.parse config.tunnel
  end

  class Spec < Struct.new(:protocol, :host, :remote_port, :local_port)
    def inspect
      "#{protocol}: #{host}:#{remote_port} <= localhost:#{local_port}"
    end
  end

  def tunnels
    urls, ports = config.urls, config.ports.split(",") 
    urls.zip(ports).map do |url, local_port|
      uri = URI.parse(url)
      Spec.new uri.scheme, tunnel_uri.host, uri.port, local_port || uri.port
    end
  end

  # return an arry [ [name, command ], [name, command ], .. ]
  def command
    port_mappings = tunnels.map do |tunnel|
      "-R 0.0.0.0:#{tunnel.remote_port}:localhost:#{tunnel.local_port}"
    end

    cmd = <<-SHELL
      env AUTOSSH_GATETIME=0
      #{Which::AUTOSSH}
      -M 0
      -F #{T::SSH_CONFIG}
      #{tunnel_uri.user}@#{tunnel_uri.host}
      -p #{tunnel_uri.port}
      #{port_mappings.join(" ")}
      -i #{T::SSH_PRIVKEY}
      -o StrictHostKeyChecking=no
      -o UserKnownHostsFile=pipe2me.known_hosts
      -o PasswordAuthentication=no
      -o ExitOnForwardFailure=yes 
      -N
    SHELL
    
    cmd.gsub(/\s+/, " ")
  end
end
