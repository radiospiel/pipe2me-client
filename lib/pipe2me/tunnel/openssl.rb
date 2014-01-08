module Pipe2me::Tunnel::OpenSSL
  HTTP = Pipe2me::HTTP

  SSL_KEY     = Pipe2me::Tunnel::SSL_KEY
  SSL_CERT    = Pipe2me::Tunnel::SSL_CERT

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
