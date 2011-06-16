NAME = simplyread
VERSION = 0.5
WEBSITE = http://njw.me.uk/software/$(NAME)/
KEYFILE = private.pem

all: dist xpi crx

web: web/index.html web/gecko-updates.rdf web/chromium-updates.xml

sign:
	gpg -b < $(NAME)-$(VERSION).tar.bz2 > $(NAME)-$(VERSION).tar.bz2.sig
	echo $(NAME)-$(VERSION).tar.bz2.sig
	gpg -b < $(NAME)-$(VERSION).xpi > $(NAME)-$(VERSION).xpi.sig
	echo $(NAME)-$(VERSION).tar.xpi.sig
	gpg -b < $(NAME)-$(VERSION).crx > $(NAME)-$(VERSION).crx.sig
	echo $(NAME)-$(VERSION).tar.crx.sig

# TODO: test makefile dependency is portable (and correct)
web/gecko-updates.rdf: web/$(NAME)-$(VERSION).xpi
	uhura -o $@ -k $(KEYFILE) $(NAME)-$(VERSION).xpi $(WEBSITE)/$(NAME)-$(VERSION).xpi

# gensig not working yet
#web/gecko-updates.rdf: gecko/updates.ttl
#	sed -e "s/VERSION/$(VERSION)/g" \
#		-e "s/HASH/`sha1sum $(NAME)-$(VERSION).xpi|awk '{print $$1}'`/g" \
#		-e "s/SIG/`sh gecko/gensig.sh gecko/updates.ttl $(KEYFILE)`/g" \
#		< $< | rapper -i turtle -o rdfxml /dev/stdin 2>/dev/null > $@

web/chromium-updates.xml: chromium/updates.xml
	sed "s/VERSION/$(VERSION)/g" < $< > $@

web/index.html: web/doap.ttl README webheader.html
	echo making webpage
	cat < webheader.html > $@
	smu < README >> $@
	echo '<h3><a href="$(NAME)-$(VERSION).tar.bz2">Download SimplyRead $(VERSION)</a><br />' >> $@
	echo '<a href="$(NAME)-$(VERSION).tar.bz2.sig">GPG signature</a></h3>' >> $@
	echo '<h3><a href="$(NAME)-$(VERSION).xpi">SimplyRead $(VERSION) for Firefox</a><br />' >> $@
	echo '<a href="$(NAME)-$(VERSION).xpi.sig">GPG signature</a></h3>' >> $@
	echo '<h3><a href="$(NAME)-$(VERSION).crx">SimplyRead $(VERSION) for Chromium</a><br />' >> $@
	echo '<a href="$(NAME)-$(VERSION).xpi.crx">GPG signature</a></h3>' >> $@
	echo '<hr />' >> $@
	sh websummary.sh web/doap.ttl | smu >> $@
	echo '</body></html>' >> $@

dist:
	mkdir -p $(NAME)-$(VERSION)
	cp simplyread.js keybind.js icon.svg COPYING INSTALL README Makefile $(NAME)-$(VERSION)
	cp -R gecko chromium tests $(NAME)-$(VERSION)
	tar -c $(NAME)-$(VERSION) | bzip2 -c > $(NAME)-$(VERSION).tar.bz2
	rm -rf $(NAME)-$(VERSION)
	echo $(NAME)-$(VERSION).tar.bz2

xpi:
	rm -rf $(NAME)-$(VERSION).xpi gecko-build
	mkdir -p gecko-build/chrome/content
	cp COPYING gecko/chrome.manifest gecko-build/
	cp gecko/chrome/content/simplyread.xul gecko-build/chrome/content/
	cp simplyread.js gecko-build/chrome/content/
	rsvg -w 22 -h 22 icon.svg gecko-build/chrome/content/icon.png
	#rsvg -w 64 -h 64 icon.svg gecko-build/icon.png
	cp icon.svg gecko-build/icon.svg
	sed -e "s/VERSION/$(VERSION)/g" -e "s/PUBKEY/`sh gecko/genpub.sh $(KEYFILE)`/g" \
		< gecko/install.ttl | rapper -i turtle -o rdfxml /dev/stdin 2>/dev/null > gecko-build/install.rdf
	cd gecko-build; zip -r ../$(NAME)-$(VERSION).xpi . 1>/dev/null
	rm -rf gecko-build
	echo $(NAME)-$(VERSION).xpi

crx:
	rm -rf chromium-build
	mkdir chromium-build
	cp COPYING simplyread.js keybind.js chromium/viable.js chromium/background.html chromium-build/
	rsvg -w 19 -h 19 icon.svg chromium-build/icon.png
	rsvg -w 48 -h 48 icon.svg chromium-build/icon48.png
	rsvg -w 128 -h 128 icon.svg chromium-build/icon128.png
	sed "s/VERSION/$(VERSION)/g" < chromium/manifest.json > chromium-build/manifest.json
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
