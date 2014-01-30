class Pipe2me::CLI < Thor
  desc "start", "Start tunnels"
  option :echo, :type => :boolean, :banner => "Also run echo servers"
  def start
    handle_global_options

    procfile = options[:echo] ? "pipe2me.procfile.echo" : "pipe2me.procfile"

    File.open procfile, "w" do |io|
      Pipe2me::Tunnel.tunnel_commands.each do |name, cmd|
        io.write "#{name}: #{cmd}\n"
      end

      next unless options[:echo]

      Pipe2me::Tunnel.echo_commands.each do |name, cmd|
        io.write "#{name}: #{cmd}\n"
      end
    end

    config = Pipe2me::Tunnel.send(:config)
    fqdn = config[:fqdn]

    Pipe2me::Tunnel.tunnels.each do |protocol, remote_port, local_port|
      UI.success "Tunneling #{protocol}://localhost:#{local_port} <=> #{protocol}://#{fqdn}:#{remote_port}"
    end

    Kernel.exec "foreman start -f #{procfile}"
  end
end
