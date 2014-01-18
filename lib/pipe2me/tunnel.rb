require "pipe2me/ext/http"
require "pipe2me/ext/sys"
require "pipe2me/ext/shell_format"

module Pipe2me::Tunnel
  # file names
  SSL_KEY     = "pipe2me.openssl.priv"
  SSL_CERT    = "pipe2me.openssl.cert"

  SSH_PUBKEY  = "pipe2me.id_rsa.pub"
  SSH_PRIVKEY = "pipe2me.id_rsa"
end

require_relative "tunnel/openssl"
require_relative "tunnel/ssh"
require_relative "tunnel/commands"

module Pipe2me::Tunnel
  ShellFormat = Pipe2me::ShellFormat
  include Pipe2me::Sys

  include OpenSSL
  include SSH
  include Commands

  extend self

  def setup(options)
    if File.exists?("pipe2me.info.inc")
      raise "Found existing pipe2me configuration in #{Dir.getwd}"
    end

    # [todo] escape auth option
    response = HTTP.post! "#{Pipe2me::Config.server}/tunnels/#{options[:auth]}",
      "protocols" => options[:protocols]

    server_info = ShellFormat.parse(response)

    raise(ArgumentError, "Missing :fqdn information") unless server_info[:fqdn]

    ShellFormat.write "pipe2me.info.inc", server_info
    ShellFormat.write "pipe2me.local.inc",
                        :server => Pipe2me::Config.server,
                        :ports => options[:ports]

    server_info
  end

  private

  # The base URL for this tunnels' configuration
  def url
    "#{config.server}/tunnels/#{config.id}"
  end

  def config
    @config ||= begin
      hsh = { :ports => [] }
      hsh.update ShellFormat.read("pipe2me.info.inc")
      hsh.update ShellFormat.read("pipe2me.local.inc")
      OpenStruct.new hsh
    end
  end

  public

  def update
    unless File.exists?(SSH_PRIVKEY)
      ssh_keygen
    end
    unless File.exists?(SSL_KEY)
      ssl_keygen
    end
    unless File.exists?(SSL_CERT)
      ssl_certsign
    end
  end
end
