#!/usr/bin/env roundup
describe "ssh key creation"

. $(dirname $1)/testhelper.inc

it_sets_up_ssh_identity() {
  fqdn=$($pipe2me setup --server $pipe2me_server --token $pipe2me_token)
  test -f pipe2me.id_rsa.pub
  test -f pipe2me.id_rsa

  # identity must contain $fqdn
  cat pipe2me.id_rsa.pub | grep $fqdn
}
