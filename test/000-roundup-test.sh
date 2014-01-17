#!/usr/bin/env roundup
describe "Is roundup working?"

it_exits_non_zero() {
  roundup=$(which roundup)
  test "" != $roundup
}
