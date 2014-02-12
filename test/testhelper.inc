# The pipe2me binary to test
pipe2me=$(cd $(dirname $1)/../bin && pwd)/pipe2me
# pipe2me_server=http://test.pipe2.me

# Load test scenario settings
echo "Load $TEST_ENV test settings"
if [ -z "$TEST_ENV" ]; then
  TEST_ENV=debug
fi

. $(dirname $1)/testhelper.${TEST_ENV}

# A temporary workspace to run tests.
scrub=$(cd $(dirname $1)/../tmp && pwd)/scrub

before() {
  mkdir -p $scrub
  cd $scrub
}

after() {
  cd ..
  rm -rf $scrub
}
