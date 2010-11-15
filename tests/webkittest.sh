#!/bin/sh
#
# This test requires surf from http://surf.suckless.org,
# patched with surfuri_js.patch

test $# -ne 2 && echo usage $0 testhtml expectedoutput && exit 1

testjs=tests/showsimple.js
htmlloadtime=2
scriptloadtime=3
scriptjs=$HOME/.surf/script.js

touch $scriptjs
test $scriptjs && mv $scriptjs $scriptjs.real
cp simplyread.js $scriptjs

trap 'rm -f testxid testoutput testoutputbody $scriptjs;mv $scriptjs.real $scriptjs' EXIT

surf -x "file://./$1" > testxid 2>testoutput &
pid=$!
sleep $htmlloadtime
xid=`cat testxid`
xprop -id $xid -f _SURF_GO 8t -set _SURF_GO "javascript:`cat $testjs`"
sleep $scriptloadtime
kill $pid

sed 's/^\*\* Message:[^<]*//g' < testoutput > testoutputbody

diff "$2" testoutputbody
result=$?

exit $result
