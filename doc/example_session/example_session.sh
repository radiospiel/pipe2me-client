TEMP_DIR=$(mktemp -d)

cd "$TEMP_DIR"

pipe2me setup --protocols http,https \
       --server http://test.pipe2.me:8080 \
       --token review@pipe2me --ports 9090,9091

cat pipe2me.info.inc

source pipe2me.info.inc

pipe2me start --echo &

sleep 5s # wait until startup has completed

# now connect to the externally accessible URLs
curl "$PIPE2ME_URLS_0/hello"

curl -k "$PIPE2ME_URLS_1/hello"

