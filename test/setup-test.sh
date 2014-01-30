#!/usr/bin/env roundup
describe "tunnel setup"

. $(dirname $1)/testhelper.inc

# setup a tunnel
it_sets_up_tunnels() {
  fqdn=$($pipe2me setup --server $pipe2me_server --token $pipe2me_token --ports 8100,8101 --protocols http,https)

  test "$fqdn" != ""

  # pipe2me setup --server $pipe2me_server returns the fqdn of the subdomain and nothing else
  test 1 -eq $(echo $fqdn | wc -l)

  # The subdomain is actually a subdomain.
  echo $fqdn | grep \.pipe2\.

  # Cannot setup a second tunnel in the same directory.
  ! $pipe2me setup --server $pipe2me_server --token $pipe2me_token
}
