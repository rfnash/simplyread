NAME = simplyread
VERSION = 0.4

index.html: doap.ttl README webheader.html
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
	sh websummary.sh doap.ttl | smu >> $@
	echo '</body></html>' >> $@

dist:
	mkdir -p $(NAME)-$(VERSION)
	cp simplyread.js keybind.js COPYING INSTALL README Makefile $(NAME)-$(VERSION)
	cp -R gecko chromium tests $(NAME)-$(VERSION)
	tar -c $(NAME)-$(VERSION) | bzip2 -c > $(NAME)-$(VERSION).tar.bz2
	gpg -b < $(NAME)-$(VERSION).tar.bz2 > $(NAME)-$(VERSION).tar.bz2.sig
	rm -rf $(NAME)-$(VERSION)
	echo $(NAME)-$(VERSION).tar.bz2 $(NAME)-$(VERSION).tar.bz2.sig

xpi:
	rm -rf $(NAME)-$(VERSION).xpi gecko-build
	mkdir -p gecko-build/chrome/content
	cp COPYING gecko/chrome.manifest gecko-build/
	cp gecko/chrome/content/simplyread.xul gecko-build/chrome/content/
	cp simplyread.js gecko-build/chrome/content/
	rsvg gecko/chrome/content/icon.svg gecko-build/chrome/content/icon.png
	sed "s/VERSION/$(VERSION)/g" < gecko/install.rdf > gecko-build/install.rdf
	cd gecko-build; zip -r ../$(NAME)-$(VERSION).xpi . 1>/dev/null
	gpg -b < $(NAME)-$(VERSION).xpi > $(NAME)-$(VERSION).xpi.sig
	rm -rf gecko-build
	echo $(NAME)-$(VERSION).xpi $(NAME)-$(VERSION).xpi.sig

crx:
	rm -rf chromium-build
	mkdir chromium-build
	cp COPYING simplyread.js keybind.js chromium/background.html chromium-build/
	rsvg chromium/icon.svg chromium-build/icon.png
	sed "s/VERSION/$(VERSION)/g" < chromium/manifest.json > chromium-build/manifest.json
	sh chromium/makecrx.sh chromium-build chromium/private.pem > $(NAME)-$(VERSION).crx
	rm -r chromium-build
	gpg -b < $(NAME)-$(VERSION).crx > $(NAME)-$(VERSION).crx.sig
	echo $(NAME)-$(VERSION).crx $(NAME)-$(VERSION).crx.sig

# note that tests require a patched surf browser; see tests/runtest.sh
test:
	for i in tests/html/*.html; do \
		sh tests/webkittest.sh $$i $$i.simple 1>$$i.diff 2>/dev/null; \
		test $$? -eq 0 && echo "$$i passed (webkit)" \
			|| echo "$$i failed (webkit) (see $$i.diff)"; \
		test ! -s $$i.diff && rm $$i.diff; \
	done

.PHONY: dist xpi crx test
.SUFFIXES: ttl html png svg
.SILENT:
