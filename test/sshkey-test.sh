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

describe "setup creates an ssh key"
it_sets_up_tunnels() {
  fqdn=$($pipe2me setup)
  test -f pipe2me.id_rsa.pub
  test -f pipe2me.id_rsa
  cat pipe2me.id_rsa.pub | grep $fqdn
}
