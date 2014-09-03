class Pipe2me::CLI < Thor
  desc "monit", "Create monitrc file and run monit"
  option :port, :default => 5555, :banner => "control port"
  option :echo, :type => :boolean, :banner => "Also run echo servers"
  def monit(*args)
    handle_global_options

    monitrc_file = create_monitrc

    UI.warn "Running: monit -c #{monitrc_file} #{args.join(" ")}"
    Kernel.exec "monit", "-c", monitrc_file, *args
  end

  desc "monitrc", "Create monitrc file"
  option :port, :default => 5555, :banner => "control port"
  option :echo, :type => :boolean, :banner => "Also run echo servers"
  def monitrc
    handle_global_options

    monitrc_file = create_monitrc
    Kernel.exec "monit", "-c", monitrc_file, "-t"
  end

  private

  def create_monitrc
    path = options[:echo] ? "pipe2me.monitrc.echo" : "pipe2me.monitrc"

    # The daemon binary
    daemon = "#{Which::DAEMON} -D #{File.expand_path(Dir.getwd)}"

    port = options[:port]

    logfile = File.expand_path "pipe2me.monit.log"
    piddir = File.expand_path "pipe2me.monit.pids"
    FileUtils.mkdir_p piddir

    commands = []
    commands << Pipe2me::Tunnel.tunnel_command
    # commands += Pipe2me::Tunnel.mapping_commands
    commands += Pipe2me::Tunnel.echo_commands if options[:echo]

    File.open path, "w", 0600 do |io|
      require "erb"

      erb = ERB.new MONITRC_ERB
      io.write erb.result(self.send(:binding))
    end

    UI.success "Created #{path}"

    path
  end

MONITRC_ERB =  %q{
set daemon 10
set httpd port <%= port %> and use address localhost allow localhost

<% commands.each do |name, cmd| %>
check process <%= name %> with pidfile <%= piddir %>/<%= name %>.pid
  <% daemon = "#{daemon} -N --name #{name} --pidfiles #{piddir} --output #{logfile}" %>
  start program = "<%= daemon %> -- <%= cmd %>" with timeout 60 seconds
  stop program = "<%= daemon %> --stop"
<% end %>
}

end
