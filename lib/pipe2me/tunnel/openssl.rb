module Pipe2me::Tunnel::OpenSSL
  HTTP = Pipe2me::HTTP

  SSL_KEY     = Pipe2me::Tunnel::SSL_KEY
  SSL_CERT    = Pipe2me::Tunnel::SSL_CERT
  SSL_CACERT  = Pipe2me::Tunnel::SSL_CACERT

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
      "-subj", "/C=de/ST=ne/L=Berlin/O=pipe2me/CN=#{config.fqdn}",
      "-days", "7300"
  end

  # send cert signing request to server and receive certificate and root certificate.
  def ssl_certsign
    cert = HTTP.post!("#{url}/cert.pem", File.read("#{SSL_KEY}.csr"), {'Content-Type' =>'text/plain'})
    UI.debug "received certificate:\n#{cert}"

    File.write SSL_CERT, cert

    cacert = HTTP.get! "#{Pipe2me::Config.server}/cacert"
    UI.error "Got #{cacert.length} byte from #{Pipe2me::Config.server}/cacert"
    File.write SSL_CACERT, cacert
  end
end
