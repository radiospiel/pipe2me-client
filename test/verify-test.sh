#!/usr/bin/env roundup
describe "verify subcommand"

. $(dirname $1)/testhelper.inc

# setup a tunnel
it_sets_up_tunnels_and_verifies() {
  fqdn=$($pipe2me setup --server $pipe2me_server --token short@pipe2me)

  # pipe2me setup --server $pipe2me_server returns the fqdn of the subdomain and nothing else
  test 1 -eq $(echo $fqdn | wc -l)

  verified=$($pipe2me verify)
  test "$fqdn" == "$verified"

  # sleep 4 seconds. The tunnel lives for 3 seconds
  sleep 4
  ! $pipe2me verify
}
