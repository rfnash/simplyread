#!/bin/sh

test $# -ne 1 && echo "usage: $0 doap" && exit 1

rdf="$1"

q="PREFIX doap: <http://usefulinc.com/ns/doap#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
SELECT ?home ?repo ?license ?maintainer ?maintainerhome ?lang ?repotype
WHERE {
?p a doap:Project;
   doap:homepage ?home;
   doap:repository ?r;
   doap:license ?license;
   doap:programming-language ?lang;
   doap:maintainer ?m.
?r a ?repotype;
   doap:location ?repo.
?m foaf:name ?maintainer;
   foaf:homepage ?maintainerhome.
}"

roqet -q -r csv -e "$q" -D /dev/stdin < $rdf | sed '1d' \
| while read r; do
	home=`echo $r | awk -F , '{print $1}'`
	repo=`echo $r | awk -F , '{print $2}'`
	licenseuri=`echo $r | awk -F , '{print $3}'`
	maint=`echo $r | awk -F , '{print $4}'`
	mainthome=`echo $r | awk -F , '{print $5}'`
	lang=`echo $r | awk -F , '{print $6}'`
	test "$licenseuri" = "http://www.gnu.org/licenses/gpl.html" && license="GPL"
	test "$licenseuri" = "http://www.gnu.org/licenses/agpl.html" && license="AGPL"
	test "$licenseuri" = "http://creativecommons.org/licenses/MIT/" && license="MIT"
	repotype=`echo $r | awk -F , '{print $7}'`
	test "$repotype" = "http://usefulinc.com/ns/doap#GitRepository" && repocmd="git clone"

	cat <<- _EOF_
- Project homepage: [$home]($home)
- Code repository: $repocmd $repo
- Maintainer: [$maint]($mainthome)
- Language: $lang
- License: [$license]($licenseuri)
- DOAP: [${home}/doap.ttl](${home}/doap.ttl)
_EOF_
done
