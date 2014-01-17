#!/usr/bin/env roundup
describe 'a HTTP(s) connection to subdomain.$pipe2me_server redirects to subdomain.$pipe2me_server:port'

. $(dirname $1)/testhelper.inc

it_redirects_https_connections() {
  false [TODO] 'redirects https://subdomain.$pipe2me_server to https://subdomain.$pipe2me_server:port'
}

it_redirects_http_connections() {
  false [TODO] 'redirects http://subdomain.$pipe2me_server to http://subdomain.$pipe2me_server:port'
}
