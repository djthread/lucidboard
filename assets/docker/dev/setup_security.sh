#!/usr/bin/env bash

if [ "$QL_MODE" != "1" ]; then
    exit
fi

echo "Adding QL Certificate as Trusted..."

CERT_FILE=Quicken_Loans_Root_CA.crt
CERT=https://git.rockfin.com/raw/SKluck/docker-images/master/.shared/certificates/$CERT_FILE
CERT_DIR=/etc/ssl/certs

curl -sSl -o $CERT_DIR/$CERT_FILE $CERT

echo cacert=/etc/ssl/certs/Quicken_Loans_Root_CA.crt > ~/.curlrc

