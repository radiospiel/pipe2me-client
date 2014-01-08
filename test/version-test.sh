#!/usr/bin/env roundup
# `describe` the plan meaningfully.
pipe2me=$(cd $(dirname $1)/../bin && pwd)/pipe2me

describe "-h shows help"

it_shows_help() {
  help=$($pipe2me -h)
  test "" != "$help"
}
