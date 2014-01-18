class Pipe2me::CLI < Thor
  desc "start", "Start tunnels"
  option :echo, :type => :boolean, :banner => "Also run echo servers"
  def start
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

    Kernel.exec "foreman start -f #{procfile}"
  end
end
