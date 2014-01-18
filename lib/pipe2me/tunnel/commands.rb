module Pipe2me::Tunnel::Commands
  extend self

  T = Pipe2me::Tunnel

  private

  # returns an array of [ protocol, remote_port, local_port ] entries
  def tunnels
    @tunnels ||= begin
      urls, ports = config.urls, config.ports

      urls.zip(ports).map do |url, local_port|
        uri = URI.parse(url)
        [ uri.scheme, uri.port, local_port || uri.port ]
      end
    end
  end

  public

  # return an arry [ [name, command ], [name, command ], .. ]
  def tunnel_commands
    tunnel_uri = URI.parse config.tunnel

    tunnels.map do |protocol, remote_port, local_port|
      next unless cmd = port_tunnel_command(tunnel_uri, protocol, remote_port, local_port)
      [ "#{protocol}_#{remote_port}", cmd ]
    end.compact
  end

  def echo_commands
    tunnels.map do |protocol, remote_port, local_port|
      next unless cmd = echo_server_command(protocol, local_port)
      [ "echo_#{remote_port}", cmd ]
    end.compact
  end

  private

  def port_tunnel_command(tunnel_uri, protocol, remote_port, local_port)
    autossh = `which autossh`.chomp

    cmd = <<-SHELL
      env AUTOSSH_GATETIME=0                                # comments work here..
      #{autossh}
      -M 0
      #{tunnel_uri.user}@#{tunnel_uri.host}
      -p #{tunnel_uri.port}
      -R 0.0.0.0:#{remote_port}:localhost:#{local_port}
      -i #{T::SSH_PRIVKEY}
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
