#!/bin/sh
#
# Currently not working - using uhura instead.

if test $# -ne 2; then
	echo "Usage: $0 update.rdf pem"
	echo "Outputs a signature suitable for use in update.rdf"
	exit 1
fi

# serialise all but the signature entry
#	in mccoy this is serializeResource(), in mexumgen it's ser()
#	exerything else seems to rewrite things, but we *might* get away with sed-ing away the bad line and outputting as rdfxml
# sha512 hash
# sign the hash
# der encode & base64

sed '/em:signature/d' < "$1" | rapper -i turtle -o rdfxml /dev/stdin 2>/dev/null \
| sha512sum \
| openssl sha1 -sha1 -binary -sign "$2" \
| openssl enc -e -a 2>/dev/null \
| awk '{printf("%s", $0)}' | sed 's/\//\\\//g'
