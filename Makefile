NAME = readable
VERSION = 0.1

index.html: doap.ttl README
	@echo making webpage
	@cat < webheader.html > $@
	@smu < README >> $@
	@echo '<h3><a href="$(NAME)-$(VERSION).tar.bz2">Download Readable $(VERSION)</a><br />' >> $@
	@echo '<a href="$(NAME)-$(VERSION).tar.bz2.sig">GPG signature</a></h3>' >> $@
	@echo '<hr />' >> $@
	@sh summary.sh doap.ttl | smu >> $@
	@echo '</body></html>' >> $@

dist:
	@mkdir -p $(NAME)-$(VERSION)
	@cp readable.js COPYING INSTALL README $(NAME)-$(VERSION)
	@tar -c $(NAME)-$(VERSION) | bzip2 -c > $(NAME)-$(VERSION).tar.bz2
	@gpg -b < $(NAME)-$(VERSION).tar.bz2 > $(NAME)-$(VERSION).tar.bz2.sig
	@rm -rf $(NAME)-$(VERSION)
	@ln -sf $(NAME)-$(VERSION).tar.bz2 latest.tar.bz2
	@ln -sf $(NAME)-$(VERSION).tar.bz2.sig latest.tar.bz2.sig
	@echo $(NAME)-$(VERSION).tar.bz2 $(NAME)-$(VERSION).tar.bz2.sig

xpi: readable.js gecko/install.rdf gecko/chrome.manifest gecko/chrome/content/readable.xul
	rm -f readable-$(VERSION).xpi
	mkdir -p gecko-build/chrome/content
	cp COPYING gecko/chrome.manifest gecko-build/
	cp gecko/chrome/content/readable.xul gecko-build/chrome/content/
	cp readable.js gecko-build/chrome/content/readable.js
	sed "s/VERSION/$(VERSION)/g" < gecko/install.rdf > gecko-build/install.rdf
	cd gecko-build; zip -r ../readable-$(VERSION).xpi .
	rm -rf gecko-build

.PHONY: dist xpi
.SUFFIXES: ttl html
