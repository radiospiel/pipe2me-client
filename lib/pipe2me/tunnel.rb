require "pipe2me/ext/http"
require "pipe2me/ext/shell_format"

module Pipe2me::Tunnel
  HTTP = Pipe2me::HTTP
  ShellFormat = Pipe2me::ShellFormat

  extend self

  def setup(options)
    if File.exists?("pipe2me.info.inc")
      raise "Found existing pipe2me configuration in #{Dir.getwd}"
    end

    # [todo] escape auth option
    response = HTTP.post! "#{Pipe2me::Config.server}/subdomains/#{options[:auth]}",
      "protocols" => options[:protocols]

    server_info = ShellFormat.parse(response)

    raise(ArgumentError, "Missing :fqdn information") unless server_info[:fqdn]

    ShellFormat.write "pipe2me.info.inc", server_info
    ShellFormat.write "pipe2me.local.inc",
                        :server => Pipe2me::Config.server,
                        :local_ports => options[:local_ports]

    server_info
  end

  private

  # The base URL for this tunnels' configuration
  def url
    server, token = settings.values_at :server, :token
    "#{server}/subdomains/#{token}"
  end

  def settings
    @settings ||= {}.tap do |hsh|
      hsh.update ShellFormat.read("pipe2me.info.inc")
      hsh.update ShellFormat.read("pipe2me.local.inc")
    end
  end

  public

  def update
    unless File.exists?("pipe2me.id_rsa")
      ssh_keygen
    end
  end

  private

  def ssh_keygen
    fqdn = settings[:fqdn]
    system "ssh-keygen -t rsa -N '' -C #{fqdn} -f pipe2me.id_rsa >&2"
    system "chmod 600 pipe2me.id_rsa*"
    HTTP.post!("#{url}/id_rsa.pub", File.read("pipe2me.id_rsa.pub"), {'Content-Type' =>'text/plain'})
  rescue
    FileUtils.rm_rf "pipe2me.id_rsa"
    FileUtils.rm_rf "pipe2me.id_rsa.pub"
    raise
  end
end
