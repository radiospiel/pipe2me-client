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

describe "show pipe2me environment"
it_start_a_tunnel() {
  fqdn=$($pipe2me setup)
  $pipe2me env > env
  echo "== env is ============="
  cat env
  echo "== env done ============="

  cat env | grep PIPE2ME_SERVER
  cat env | grep PIPE2ME_TOKEN
  cat env | grep PIPE2ME_FQDN
  cat env | grep PIPE2ME_URLS_0
  cat env | grep PIPE2ME_TUNNEL
  ! (cat env | grep PIPE2ME_URLS_1)

  # can we source the env?
  eval $($pipe2me env)
  echo $PIPE2ME_URLS_0 | grep http
}
