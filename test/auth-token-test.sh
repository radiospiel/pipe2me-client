#!/usr/bin/env roundup
# `describe` the plan meaningfully.

. $(dirname $1)/testhelper.inc

describe "fails on invalid auth"
it_fails_on_invalid_auth() {
  ! $pipe2me setup --server $pipe2me_server --auth $pipe2me_token.invalid
}

describe "fails on missing auth"
it_fails_on_missing_auth_token() {
  ! $pipe2me setup --server $pipe2me_server
}
