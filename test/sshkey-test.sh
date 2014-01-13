#!/usr/bin/env roundup
# `describe` the plan meaningfully.

. $(dirname $1)/testhelper.inc

#
# pipe2me setup creates ssh identity
#
describe "setup creates an ssh key"
it_sets_up_ssh_identity() {
  fqdn=$($pipe2me setup --server $pipe2me_server --auth $pipe2me_token)
  test -f pipe2me.id_rsa.pub
  test -f pipe2me.id_rsa

  # identity must contain $fqdn
  cat pipe2me.id_rsa.pub | grep $fqdn
}
