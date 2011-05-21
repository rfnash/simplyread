#!/bin/sh
#
# Purpose: Pack a Chromium extension directory into crx format
#
# Based on bash script at:
# http://code.google.com/chrome/extensions/crx.html
# Licensed under the BSD license

test $# -ne 2 && echo "Usage: $0 dir pem" && exit 1

dir=$1
key=$2
pub="pubkey"
sig="sig"
zip="tmp.zip"
trap 'rm -f "$pub" "$sig" "$zip"' EXIT

wd=`pwd` && cd "$dir" && zip -qr -9 -X "$wd/$zip" . ; cd "$wd"

openssl sha1 -sha1 -binary -sign "$key" < "$zip" > "$sig"
openssl rsa -pubout -outform DER < "$key" > "$pub" 2>/dev/null

crmagic_hex="4372 3234" # Cr24
version_hex="0200 0000" # 2
# use /bin/dd as 9base dd has different syntax expectations
pub_len_hex=`stat -c %s "$pub" | xargs printf '%08x\n' | rev | /bin/dd conv=swab 2>/dev/null`
sig_len_hex=`stat -c %s "$sig" | xargs printf '%08x\n' | rev | /bin/dd conv=swab 2>/dev/null`

echo "$crmagic_hex $version_hex $pub_len_hex $sig_len_hex" | xxd -r -p
cat "$pub" "$sig" "$zip"
