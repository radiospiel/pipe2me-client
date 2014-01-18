#!/usr/bin/env roundup
describe "-h shows help"

. $(dirname $1)/testhelper.inc

it_shows_help() {
  help=$($pipe2me -h)
  test "" != "$help"
}
