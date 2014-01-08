require "pipe2me/ext/http"
require "pipe2me/ext/sys"
require "pipe2me/ext/shell_format"

module Pipe2me::Tunnel
  HTTP = Pipe2me::HTTP
  ShellFormat = Pipe2me::ShellFormat
  include Pipe2me::Sys

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

  def fqdn
    settings[:fqdn]
  end

  def settings
    @settings ||= {}.tap do |hsh|
      hsh.update ShellFormat.read("pipe2me.info.inc")
      hsh.update ShellFormat.read("pipe2me.local.inc")
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

  private

  SSL_KEY = "pipe2me.openssl.priv"
  SSL_CERT = "pipe2me.openssl.cert"

  SSH_PUBKEY = "pipe2me.id_rsa.pub"
  SSH_PRIVKEY = "pipe2me.id_rsa"

  def ssh_keygen
    sh! "ssh-keygen -t rsa -N '' -C #{fqdn} -f pipe2me.id_rsa >&2"
    sh! "chmod 600 pipe2me.id_rsa*"
    HTTP.post!("#{url}/id_rsa.pub", File.read(SSH_PUBKEY), {'Content-Type' =>'text/plain'})
  rescue
    FileUtils.rm_rf SSH_PRIVKEY
    FileUtils.rm_rf SSH_PUBKEY
    raise
  end

  def openssl_conf
    File.join(File.dirname(__FILE__), "openssl.conf")
  end

  # create openssl private key and cert signing request.
  def ssl_keygen
    sys! "openssl",
      "req", "-config", openssl_conf,
      "-new", "-nodes",
      "-keyout", SSL_KEY,
      "-out", "#{SSL_KEY}.csr",
      "-subj", "/C=de/ST=ne/L=Berlin/O=pipe2me/CN=#{fqdn}",
      "-days", "7300"
  end

  # send cert signing request to server and receive certificate
  def ssl_certsign
    cert = HTTP.post!("#{url}/cert.pem", File.read("#{SSL_KEY}.csr"), {'Content-Type' =>'text/plain'})
    UI.debug "received certificate:\n#{cert}"

    File.atomic_write SSL_CERT, cert
  end
end
