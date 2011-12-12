NAME = simplyread
UPNAME = SimplyRead
VERSION = 0.8
KEYFILE = private.pem

WEBSITE = http://njw.me.uk/software/$(NAME)
REPOURL = http://git.njw.me.uk/$(NAME).git
AUTHORFOAF = http://njw.me.uk/card#i
AUTHORNAME = Nick White
AUTHORHOME = http://njw.me.uk
GECKOID = simplyread@njw.me.uk

all: xpi crx

web: web/index.html web/gecko-updates.rdf web/chromium-updates.xml

$(KEYFILE):
	openssl genrsa 1024 > $@

sign:
	if test -f $(NAME)-$(VERSION).tar.bz2; then \
		gpg -b < $(NAME)-$(VERSION).tar.bz2 > $(NAME)-$(VERSION).tar.bz2.sig; \
		echo $(NAME)-$(VERSION).tar.bz2.sig; fi
	if test -f $(NAME)-$(VERSION).xpi; then \
		gpg -b < $(NAME)-$(VERSION).xpi > $(NAME)-$(VERSION).xpi.sig; \
		echo $(NAME)-$(VERSION).tar.xpi.sig; fi
	if test -f $(NAME)-$(VERSION).crx; then \
		gpg -b < $(NAME)-$(VERSION).crx > $(NAME)-$(VERSION).crx.sig; \
		echo $(NAME)-$(VERSION).tar.crx.sig; fi

# TODO: test makefile dependency is portable (and correct)
web/gecko-updates.rdf: $(NAME)-$(VERSION).xpi $(KEYFILE)
	uhura -o $@ -k $(KEYFILE) $(NAME)-$(VERSION).xpi $(WEBSITE)/$(NAME)-$(VERSION).xpi

# gensig not working yet
#web/gecko-updates.rdf: gecko/updates.ttl
#	sed -e "s/VERSION/$(VERSION)/g" \
#		-e "s|WEBSITE|$(WEBSITE)|g" \
#		-e "s|GECKOID|$(GECKOID)|g" \
#		-e "s/HASH/`sha1sum $(NAME)-$(VERSION).xpi|awk '{print $$1}'`/g" \
#		-e "s/SIG/`sh gecko/gensig.sh gecko/updates.ttl $(KEYFILE)`/g" \
#		< $< | rapper -i turtle -o rdfxml /dev/stdin 2>/dev/null > $@

web/chromium-updates.xml: chromium/updates.xml
	sed -e "s/VERSION/$(VERSION)/g" -e "s|WEBSITE|$(WEBSITE)|g" < $< > $@

web/doap.ttl: web/doap-src.ttl
	sed -e "s|FOAF|$(AUTHORFOAF)|g" -e "s|AUTHORNAME|$(AUTHORNAME)|g" \
	    -e "s|AUTHORHOME|$(AUTHORHOME)|g" -e "s|WEBSITE|$(WEBSITE)|g" \
	    -e "s|REPOURL|$(REPOURL)|g" < $< > $@

web/index.html: web/doap.ttl README
	echo making webpage
	echo "<!DOCTYPE html><html><head><title>$(UPNAME)</title>" > $@
	echo '<link rel="alternate" type="text/turtle" title="rdf" href="doap.ttl" />' >> $@
	echo '<style type="text/css">' >> $@
	echo "body {font-family:sans-serif; width:38em; margin:auto; max-width:94%;}" >> $@
	echo "h1 {font-size:1.6em; text-align:center;}" >> $@
	echo "a {text-decoration:none; border-bottom-width:thin; border-bottom-style:dotted;}" >> $@
	echo "</style></head><body>" >> $@
	smu < README >> $@
	echo "[$(UPNAME) $(VERSION) source]($(NAME)-$(VERSION).tar.bz2) ([sig]($(NAME)-$(VERSION).tar.bz2.sig))" | smu >> $@

	echo "[$(UPNAME) $(VERSION) for Firefox]($(NAME)-$(VERSION).xpi) ([sig]($(NAME)-$(VERSION).xpi.sig))" | smu >> $@

	echo "[$(UPNAME) $(VERSION) for Chromium]($(NAME)-$(VERSION).crx) ([sig]($(NAME)-$(VERSION).crx.sig))" | smu >> $@

	echo '<hr />' >> $@
	sh web/websummary.sh web/doap.ttl | smu >> $@
	echo '</body></html>' >> $@

dist:
	mkdir -p $(NAME)-$(VERSION)
	cp simplyread.js viable.js keybind.js icon.svg COPYING INSTALL README Makefile $(NAME)-$(VERSION)
	cp -R gecko chromium $(NAME)-$(VERSION)
	tar -c $(NAME)-$(VERSION) | bzip2 -c > $(NAME)-$(VERSION).tar.bz2
	rm -rf $(NAME)-$(VERSION)
	echo $(NAME)-$(VERSION).tar.bz2

xpi: $(KEYFILE)
	rm -rf $(NAME)-$(VERSION).xpi gecko-build
	mkdir -p gecko-build/chrome/content gecko-build/defaults/preferences
	sed 2q < COPYING > gecko-build/COPYING
	cp gecko/chrome.manifest gecko/options.xul gecko-build/
	cp gecko/chrome/content/simplyread.xul gecko-build/chrome/content/
	cp gecko/defaults/preferences/prefs.js gecko-build/defaults/preferences/
	patch < gecko/js.patch > /dev/null
	cp simplyread.js gecko-build/chrome/content/
	cat viable.js gecko/viablehook.js > gecko-build/chrome/content/viable.js
	rsvg -w 22 -h 22 icon.svg gecko-build/chrome/content/icon.png
	rsvg -w 64 -h 64 icon.svg gecko-build/icon.png
	sed -e "s/VERSION/$(VERSION)/g" -e "s|WEBSITE|$(WEBSITE)|g" -e "s|GECKOID|$(GECKOID)|g" -e "s/PUBKEY/`sh gecko/genpub.sh $(KEYFILE)`/g" \
		< gecko/install.ttl | rapper -i turtle -o rdfxml /dev/stdin 2>/dev/null > gecko-build/install.rdf
	cd gecko-build; zip -r ../$(NAME)-$(VERSION).xpi . 1>/dev/null
	rm -rf gecko-build
	patch -R < gecko/js.patch > /dev/null
	echo $(NAME)-$(VERSION).xpi

crx: $(KEYFILE)
	rm -rf chromium-build
	mkdir chromium-build
	sed 2q < COPYING > chromium-build/COPYING
	cp simplyread.js keybind.js chromium-build/
	cp chromium/background.html chromium/options.html chromium-build/
	cat viable.js chromium/viablehook.js > chromium-build/viable.js
	rsvg -w 19 -h 19 icon.svg chromium-build/icon.png
	rsvg -w 48 -h 48 icon.svg chromium-build/icon48.png
	rsvg -w 128 -h 128 icon.svg chromium-build/icon128.png
	sed -e "s/VERSION/$(VERSION)/g" -e "s|WEBSITE|$(WEBSITE)|g" < chromium/manifest.json > chromium-build/manifest.json
	sh chromium/makecrx.sh chromium-build $(KEYFILE) > $(NAME)-$(VERSION).crx
	rm -r chromium-build
	echo $(NAME)-$(VERSION).crx

# note that tests require a patched surf browser; see tests/runtest.sh
test:
	for i in tests/html/*.html; do \
		sh tests/webkittest.sh $$i $$i.simple 1>$$i.diff 2>/dev/null; \
		test $$? -eq 0 && echo "$$i passed (webkit)" \
			|| echo "$$i failed (webkit) (see $$i.diff)"; \
		test ! -s $$i.diff && rm $$i.diff; \
	done

.PHONY: all dist xpi crx test web sign
.SUFFIXES: ttl html png svg
.SILENT:
