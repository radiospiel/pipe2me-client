# pipe2me client

This is the ruby client for the pipe2me server package.
The pipe2me client lets you publish local services to the public internet
with the help and orchestration of a pipe2me server. For more details
see [pipe2me](https://github.com/kinko/pipe2me)

## Installation

The pipe2me-client works with ruby 2.0. It might work with older rubies also.
To install it run

    gem install pipe2me-client
    # optional: install man page
    sudo cp doc/pipe2me.1 /usr/local/share/man/man1

If you are managing a box with a system-wide ruby installation you must install
it via

    sudo gem install pipe2me-client

Verify the installation with

    which pipe2me

## Usage

Mini-example: This registers two tunnels with a single hostname for
two services on localhost (http on port 9090, https on port 9091).

<pre>
# Setup tunnels. This responds with the domain name
&gt; <b>pipe2me setup --protocols http,https \
       --server http://test.pipe2.me:8080 \
       --token review@pipe2me --ports 9090,9091</b>
pretty-ivory-horse.test.pipe2.me

# Review the assigned URLs:
&gt; <b>cat pipe2me.info.inc | grep URL</b>
PIPE2ME_URLS_0=http://pretty-ivory-horse.test.pipe2.me:10003
PIPE2ME_URLS_1=https://pretty-ivory-horse.test.pipe2.me:10004

# Start the tunnels via foreman (but please review on using foreman)
&gt; <b>pipe2me start</b>
</pre>

See also the [example session](http://test.pipe2.me/example_session.html)
and the [man page](http://test.pipe2.me/pipe2me.1.html).

## Testing

Tests are implemented using
[roundup](https://github.com/bmizerany/roundup/blob/master/INSTALLING#files).
To install roundup on OSX, run `brew install roundup`. Other systems are
supported as well, compare roundup's documentation for details.

The implemented tests are *integration tests* in the sense, that they test the
behaviour of the *pipe2me-client* package in connection to an external pipe2me
server. That means you should run a pipe2me server on your local machine. Note
that the server must be configured to support test mode. (In test mode a pipe2me
server accepts test auth tokens, that create short lived tunnels
with self-signed certificates.)

To run the tests against a locally installed test server run `rake`. Note that
the local test server is expected at "pipe2.dev:8080". You might have to adjust
the `/etc/hosts` file to add an entry

    127.0.0.1    pipe2.dev

Before submitting a pull request you should also run a test against the
test.pipe2.me instance, which is available most of the time for that purpose.
To do that, run `rake test:release`.

## Tunnel tokens

As ports and domain names are sparse resources the pipe2me server API
requires the use of authorization tokens when requesting a tunnel. A
token is similar to a 'currency' in that it describes which tunnels are
supported. A token could limit the number of ports that can be tunnelled,
the amount of traffic for those ports, whether or not a certificate is
self-signed or signed by a regular CA, etc.


The features of a token are not defined within this protocol. However,
there has to be one. Contact the administrator of the pipe2me server
to know more.

A freshly installed pipe2me server comes with a number of preconfigured tokens.
Of course, a server admin should (and probably would) change those tokens.
However, as a test target, the pipe2me test server at http://test.pipe2.me:8080
supports these tokens:

- `test@pipe2me`: this builds tunnels that are available for 5 minutes.
  The test token is intended for use with automated test scenarios.
- `review@pipe2me`: this builds tunnels that are available for up to
  one day. A review token should help you get a feel for the pipe2me
  package.

If you need a longer lived token for development, review and/or test
feel free to contact us at contact@kinko.me.

## Licensing

**The pipe2me client software** is (c) The Kinko Team, 2014 and released to you
under the terms of the MIT License (MIT), see COPYING.MIT for details.

The subdirectory lib/vendor contains third-party code, which is subject to its own copyrights.
Please see the respective source files for copyright information.

(c) The kinko team, 2014
