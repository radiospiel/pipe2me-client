#!/usr/bin/env roundup
describe "SSL tests"

# This file contains tests related to SSL functionality.
#

. $(dirname $1)/testhelper.inc

# setup creates and signs openssl credentials
it_sets_up_ssl_certs() {
  # setup the pipe2me client. This must create a private key and a server
  # certificate, amongst other things. The certificate must contain the
  # correct name.

  fqdn=$($pipe2me setup --server $pipe2me_server --token $pipe2me_token)

  # test for private key
  cat pipe2me.openssl.priv | grep -E "BEGIN.*PRIVATE KEY"

  # test for CAcert
  cat pipe2me.cacert | grep "BEGIN CERTIFICATE"

  # test for certificate
  cat pipe2me.openssl.cert | grep "BEGIN CERTIFICATE"

  # verify name in certificate
  openssl x509 -in pipe2me.openssl.cert  -text | grep CN=$fqdn
}
