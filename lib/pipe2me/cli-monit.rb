class Pipe2me::CLI < Thor
  MONITRC = "pipe2me.monitrc"

  desc "monit", "Create monitrc file and run monit"
  option :port, :banner => "control port", :default => 5555
  def monit(*args)
    create_monitrc(options) unless File.exists?(MONITRC)

    UI.warn "Running: monit -c #{MONITRC} #{args.join(" ")}"
    Kernel.exec "monit", "-c", MONITRC, *args
  end

  desc "monitrc", "Create monitrc file"
  option :port, :banner => "control port", :default => 5555
  def monitrc
    create_monitrc(options)
    Kernel.exec "monit", "-c", MONITRC, "-t"
  end

  private

  def create_monitrc(options)
    port = options[:port]
    logfile = File.expand_path "pipe2me.monit.log"
    piddir = File.expand_path "pipe2me.monit.pids"
    FileUtils.mkdir_p piddir

    File.atomic_write MONITRC do |io|
      require "erb"

      erb = ERB.new MONITRC_ERB
      io.write erb.result(self.send(:binding))
    end

    FileUtils.chmod 0600, MONITRC

    UI.success "Created #{MONITRC}"
  end

MONITRC_ERB =  %q{
<%
  daemon_bin = `which daemon`.chomp
  daemon = "#{daemon_bin} -D #{File.expand_path(Dir.getwd)}"
%>

set daemon 10
set httpd port <%= port %> and use address localhost allow localhost

<% Pipe2me::Tunnel.tunnel_commands.each do |name, cmd| %>
check process <%= name %> with pidfile <%= piddir %>/<%= name %>.pid
  <% daemon = "#{daemon} -N --name #{name} --pidfiles #{piddir} --output #{logfile}" %>
  start program = "<%= daemon %> -- <%= cmd %>" with timeout 60 seconds
  stop program = "<%= daemon %> --stop"
<% end %>
}

end
