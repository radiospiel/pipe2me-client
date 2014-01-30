#!/usr/bin/env roundup
describe "fails on invalid and missing auth"

. $(dirname $1)/testhelper.inc

it_fails_on_invalid_auth() {
  ! $pipe2me setup --server $pipe2me_server --token $pipe2me_token.invalid
}

it_fails_on_missing_auth_token() {
  ! $pipe2me setup --server $pipe2me_server
}
