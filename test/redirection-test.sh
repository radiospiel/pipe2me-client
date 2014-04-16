#!/usr/bin/env roundup
describe 'a HTTP(s) connection to subdomain.$pipe2me_server redirects to subdomain.$pipe2me_server:port'

. $(dirname $1)/testhelper.inc

# redirects https://subdomain.$pipe2me_server to https://subdomain.$pipe2me_server:port

it_redirects_http_and_https_connections() {
  # later 'redirects https://subdomain.$pipe2me_server to https://subdomain.$pipe2me_server:port'
  fqdn=$($pipe2me setup --server $pipe2me_server --token $pipe2me_token --ports 8100,8101 --protocols http,https)

  # load pipe2me environment settings. As a result, ..
  eval $($pipe2me env)

  [ "$PIPE2ME_URLS_0" ]       # .. PIPE2ME_URLS_0 is the HTTP redirection target URL, and ..
  [ "$PIPE2ME_URLS_1" ]       # .. PIPE2ME_URLS_1 is the HTTPS redirection target URL

  https_redirection_target=$(curl -s -o /dev/null -I -k -w %{redirect_url} https://$fqdn:8443)
  [ $PIPE2ME_URLS_1/ = "$https_redirection_target" ]

  http_redirection_target=$(curl -s -o /dev/null -I -w %{redirect_url} http://$fqdn:8080)
  [ $PIPE2ME_URLS_0/ = "$http_redirection_target" ]
}

it_redirects_http_to_https_if_needed() {
  # later 'redirects https://subdomain.$pipe2me_server to https://subdomain.$pipe2me_server:port'
  fqdn=$($pipe2me setup --server $pipe2me_server --token $pipe2me_token --ports 8100 --protocols https)

  # load pipe2me environment settings. As a result, ..
  eval $($pipe2me env)

  [[ "$PIPE2ME_URLS_0" ]]           # .. PIPE2ME_URLS_0 is the HTTPS redirection target URL, and ..
  [[ -z "$PIPE2ME_URLS_1" ]]        # .. PIPE2ME_URLS_1 is the HTTPS redirection target URL

  https_redirection_target=$(curl -s -o /dev/null -I -k -w %{redirect_url} https://$fqdn:8443)
  [ $PIPE2ME_URLS_0/ = "$https_redirection_target" ]

  http_redirection_target=$(curl -s -o /dev/null -I -w %{redirect_url} http://$fqdn:8080)
  [ $PIPE2ME_URLS_0/ = "$http_redirection_target" ]
}

it_does_not_redirects_https_to_http() {
  # later 'redirects https://subdomain.$pipe2me_server to https://subdomain.$pipe2me_server:port'
  fqdn=$($pipe2me setup --server $pipe2me_server --token $pipe2me_token --ports 8100 --protocols http)

  # load pipe2me environment settings. As a result, ..
  eval $($pipe2me env)

  [[ "$PIPE2ME_URLS_0" ]]           # .. PIPE2ME_URLS_0 is the HTTPS redirection target URL, and ..
  [[ -z "$PIPE2ME_URLS_1" ]]        # .. PIPE2ME_URLS_1 is the HTTPS redirection target URL

  https_redirection_target=$(curl -s -o /dev/null -I -k -w %{redirect_url} https://$fqdn:8443)
  [[ -z "$https_redirection_target" ]]

  http_redirection_target=$(curl -s -o /dev/null -I -w %{redirect_url} http://$fqdn:8080)
  [[ $PIPE2ME_URLS_0/ = "$http_redirection_target" ]]
}
