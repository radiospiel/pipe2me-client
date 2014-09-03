require "pipe2me/ext/http"
require "pipe2me/ext/sys"
require "pipe2me/ext/shell_format"

module Pipe2me::Tunnel
  # file names
  SSL_KEY     = "pipe2me.openssl.priv"
  SSL_CERT    = "pipe2me.openssl.cert"
  SSL_CACERT  = "pipe2me.cacert"

  SSH_PUBKEY  = "pipe2me.id_rsa.pub"
  SSH_PRIVKEY = "pipe2me.id_rsa"

  SSH_CONFIG  = "pipe2me.ssh_config"
  
  def clear
    [ 
      SSL_KEY, SSL_CERT, SSL_CACERT, SSH_PUBKEY, SSH_PRIVKEY, SSH_CONFIG,
      "pipe2me.info.inc", "pipe2me.local.inc",
      "pipe2me.openssl.priv.csr", "pipe2me.openssl.rnd"
    ].each do |base|
        next unless File.exist?(base)
        UI.info "Deleting #{base}" 
        FileUtils.rm base
    end
  end
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
    response = HTTP.post! "#{Pipe2me.server}/tunnels/#{options[:token]}",
      "protocols" => options[:protocols]

    server_info = ShellFormat.parse(response)

    raise(ArgumentError, "Missing :fqdn information") unless server_info[:fqdn]

    ShellFormat.write "pipe2me.info.inc", server_info
    ShellFormat.write "pipe2me.local.inc",
                        :server => Pipe2me.server,
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

  def verify
    HTTP.get! "#{url}/verify"
    puts config.fqdn
  end

  def check
    r = HTTP.get! "#{url}/check"
    puts r
  end

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
    unless File.exists?(SSH_CONFIG)
      FileUtils.cp "#{File.dirname(__FILE__)}/tunnel/ssh_config", SSH_CONFIG
    end
  end
end
