#!/usr/bin/env roundup
# `describe` the plan meaningfully.
. $(dirname $1)/testhelper.inc

describe "-h shows help"

it_shows_help() {
  help=$($pipe2me -h)
  test "" != "$help"
}
