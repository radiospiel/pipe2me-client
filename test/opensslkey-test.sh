#!/usr/bin/env roundup
# `describe` the plan meaningfully.

pipe2me=$(cd $(dirname $1)/../bin && pwd)/pipe2me

before() {
  mkdir scrub
  cd scrub
}

after() {
  cd ..
  rm -rf scrub
}

describe "setup creates and signs openssl credentials"
it_sets_up_openssl_certs() {
  fqdn=$($pipe2me setup)
  test -f pipe2me.openssl.priv
  cat pipe2me.openssl.priv | grep "BEGIN RSA PRIVATE KEY"

  test -f pipe2me.openssl.cert
  cat pipe2me.openssl.cert | grep "BEGIN CERTIFICATE"

  # verify cert name
  openssl x509 -in pipe2me.openssl.cert  -text | grep CN=$fqdn
}
