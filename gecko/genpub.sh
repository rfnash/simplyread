#!/bin/sh

if test $# -ne 1; then
	echo "Usage: $0 pem"
	echo "Outputs a public key suitable for use in install.rdf"
	exit 1
fi

openssl rsa -pubout -outform DER < "$1" 2>/dev/null \
| openssl enc -e -a 2>/dev/null \
| awk '{printf("%s", $0)}' | sed 's/\//\\\//g'
