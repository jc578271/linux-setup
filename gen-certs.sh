#!/bin/bash

# Generate some test certificates which are used by the regression test suite:
#
#   ./certs/tls/ca.{crt,key}          Self signed CA certificate.
#   ./certs/tls/redis.{crt,key}       A certificate with no key usage/policy restrictions.
#   ./certs/tls/client.{crt,key}      A certificate restricted for SSL client usage.
#   ./certs/tls/server.{crt,key}      A certificate restricted for SSL server usage.
#   ./certs/tls/redis.dh              DH Params file.
CURRENT_EXECUTE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

generate_cert() {
    local name=$1
    local cn="$2"
    local opts="$3"

    local keyfile=$CURRENT_EXECUTE_DIR/certs/tls/${name}.key
    local certfile=$CURRENT_EXECUTE_DIR/certs/tls/${name}.crt

    [ -f $keyfile ] || openssl genrsa -out $keyfile 2048
    openssl req \
        -new -sha256 \
        -subj "/O=Redis Test/CN=$cn" \
        -key $keyfile | \
        openssl x509 \
            -req -sha256 \
            -CA $CURRENT_EXECUTE_DIR/certs/tls/ca.crt \
            -CAkey $CURRENT_EXECUTE_DIR/certs/tls/ca.key \
            -CAserial $CURRENT_EXECUTE_DIR/certs/tls/ca.txt \
            -CAcreateserial \
            -days 365 \
            $opts \
            -out $certfile
}

mkdir -p $CURRENT_EXECUTE_DIR/certs/tls
[ -f $CURRENT_EXECUTE_DIR/certs/tls/ca.key ] || openssl genrsa -out $CURRENT_EXECUTE_DIR/certs/tls/ca.key 4096
openssl req \
    -x509 -new -nodes -sha256 \
    -key $CURRENT_EXECUTE_DIR/certs/tls/ca.key \
    -days 3650 \
    -subj '/O=Redis Test/CN=Certificate Authority' \
    -out $CURRENT_EXECUTE_DIR/certs/tls/ca.crt

cat > $CURRENT_EXECUTE_DIR/certs/tls/openssl.cnf <<_END_
[ server_cert ]
keyUsage = digitalSignature, keyEncipherment
nsCertType = server
subjectAltName = @alt_names

[ client_cert ]
keyUsage = digitalSignature, keyEncipherment
nsCertType = client
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost
IP.1 = 127.0.0.1
_END_

generate_cert server "Server-only" "-extfile $CURRENT_EXECUTE_DIR/certs/tls/openssl.cnf -extensions server_cert"
generate_cert client "Client-only" "-extfile $CURRENT_EXECUTE_DIR/certs/tls/openssl.cnf -extensions client_cert"
generate_cert redis "Generic-cert"

[ -f $CURRENT_EXECUTE_DIR/certs/tls/redis.dh ] || openssl dhparam -out $CURRENT_EXECUTE_DIR/certs/tls/redis.dh 2048
