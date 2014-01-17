#!/usr/bin/env roundup
# `describe` the plan meaningfully.

. $(dirname $1)/testhelper.inc

describe 'a HTTP(s) connection to subdomain.$pipe2me_server redirects to subdomain.$pipe2me_server:port'
it_sets_up_ssh_identity() {
  echo "TODO"
  false
}
