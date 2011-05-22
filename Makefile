NAME = simplyread
VERSION = 0.4
WEBSITE = http://njw.me.uk/software/$(NAME)/
KEYFILE = private.pem

all: web/chromium-updates.xml web/index.html dist xpi crx

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
	cp simplyread.js keybind.js COPYING INSTALL README Makefile $(NAME)-$(VERSION)
	cp -R gecko chromium tests $(NAME)-$(VERSION)
	tar -c $(NAME)-$(VERSION) | bzip2 -c > web/$(NAME)-$(VERSION).tar.bz2
	gpg -b < web/$(NAME)-$(VERSION).tar.bz2 > web/$(NAME)-$(VERSION).tar.bz2.sig
	rm -rf $(NAME)-$(VERSION)
	echo web/$(NAME)-$(VERSION).tar.bz2 web/$(NAME)-$(VERSION).tar.bz2.sig

xpi:
	rm -rf $(NAME)-$(VERSION).xpi gecko-build
	mkdir -p gecko-build/chrome/content
	cp COPYING gecko/chrome.manifest gecko-build/
	cp gecko/chrome/content/simplyread.xul gecko-build/chrome/content/
	cp simplyread.js gecko-build/chrome/content/
	rsvg gecko/chrome/content/icon.svg gecko-build/chrome/content/icon.png
	sed "s/VERSION/$(VERSION)/g" < gecko/install.ttl | rapper -i turtle -o rdfxml /dev/stdin 2>/dev/null > gecko-build/install.rdf
	cd gecko-build; zip -r ../web/$(NAME)-$(VERSION).xpi . 1>/dev/null
	gpg -b < web/$(NAME)-$(VERSION).xpi > web/$(NAME)-$(VERSION).xpi.sig
	rm -rf gecko-build
	echo web/$(NAME)-$(VERSION).xpi web/$(NAME)-$(VERSION).xpi.sig

crx:
	rm -rf chromium-build
	mkdir chromium-build
	cp COPYING simplyread.js keybind.js chromium/viable.js chromium/background.html chromium-build/
	rsvg -w 19 -h 19 chromium/icon.svg chromium-build/icon.png
	rsvg -w 48 -h 48 chromium/icon.svg chromium-build/icon48.png
	rsvg -w 128 -h 128 chromium/icon.svg chromium-build/icon128.png
	sed "s/VERSION/$(VERSION)/g" < chromium/manifest.json > chromium-build/manifest.json
	sh chromium/makecrx.sh chromium-build $(KEYFILE) > web/$(NAME)-$(VERSION).crx
	rm -r chromium-build
	gpg -b < web/$(NAME)-$(VERSION).crx > web/$(NAME)-$(VERSION).crx.sig
	echo web/$(NAME)-$(VERSION).crx web/$(NAME)-$(VERSION).crx.sig

# note that tests require a patched surf browser; see tests/runtest.sh
test:
	for i in tests/html/*.html; do \
		sh tests/webkittest.sh $$i $$i.simple 1>$$i.diff 2>/dev/null; \
		test $$? -eq 0 && echo "$$i passed (webkit)" \
			|| echo "$$i failed (webkit) (see $$i.diff)"; \
		test ! -s $$i.diff && rm $$i.diff; \
	done

.PHONY: all dist xpi crx test
.SUFFIXES: ttl html png svg
.SILENT:
