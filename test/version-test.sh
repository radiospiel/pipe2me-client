#!/usr/bin/env roundup
# `describe` the plan meaningfully.
describe "-h shows help"

it_shows_help() {
  help=$(../bin/pipe2me -h)
  test "" != "$help"
}
