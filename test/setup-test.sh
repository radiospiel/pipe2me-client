#!/usr/bin/env roundup
# `describe` the plan meaningfully.

. $(dirname $1)/testhelper.inc

describe "setup a tunnel"
it_sets_up_tunnels() {
  fqdn=$($pipe2me setup --server $pipe2me_server)

  # pipe2me setup --server $pipe2me_server returns the fqdn of the subdomain and nothing else
  test 1 -eq $(echo $fqdn | wc -l)

  # The subdomain is actually a subdomain.
  echo $fqdn | grep \.pipe2\.dev
}

describe "setup only one tunnel set per directory"
it_sets_up_tunnels_only_once() {
  $pipe2me setup --server $pipe2me_server
  ! $pipe2me setup --server $pipe2me_server
}
