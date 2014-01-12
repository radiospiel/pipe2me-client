#!/usr/bin/env roundup
# `describe` the plan meaningfully.

. $(dirname $1)/testhelper.inc

describe "setup creates and signs openssl credentials"
it_sets_up_openssl_certs() {
  fqdn=$($pipe2me setup --server $pipe2me_server)
  test -f pipe2me.openssl.priv
  cat pipe2me.openssl.priv | grep "BEGIN RSA PRIVATE KEY"

  test -f pipe2me.openssl.cert
  cat pipe2me.openssl.cert | grep "BEGIN CERTIFICATE"

  # verify cert name
  openssl x509 -in pipe2me.openssl.cert  -text | grep CN=$fqdn
}
