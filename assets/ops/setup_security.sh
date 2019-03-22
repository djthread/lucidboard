#!/usr/bin/env sh

if [ "$QL_MODE" != "1" ]; then
    exit
fi

echo "Adding QL Certificate as Trusted..."

curl -sLk $QL_CERTS | bash -
