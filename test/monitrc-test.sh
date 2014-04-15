#!/usr/bin/env roundup
describe "setup and starts tunnels in foreman mode"

. $(dirname $1)/testhelper.inc

it_works_with_monitrc() {
  later It setup and starts tunnels in monitrc mode
  # i.e.  pipe2me setup
  #       pipe2me monitrc
  #       pipe2me monit start all
  #       ...
}

it_creates_a_monitrc_file() {
  ! [ -e pipe2me.monitrc ]
  fqdn=$($pipe2me setup --server $pipe2me_server --token $pipe2me_token)

  $pipe2me monitrc
  [ -e pipe2me.monitrc ]

  # The file is 0600
  ls -l pipe2me.monitrc | grep -e "-rw-------"
}
