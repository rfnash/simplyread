index.html: doap.ttl README
	@echo making webpage
	@cat < webheader.html > $@
	@smu < README >> $@
	@echo '<h3><a href="latest.tar.gz">Download Readable</a><br />' >> $@
	@echo '<a href="latest.tar.gz.sig">GPG signature</a></h3>' >> $@
	@echo '<hr />' >> $@
	@sh summary.sh doap.ttl | smu >> $@
	@echo '</body></html>' >> $@

.SUFFIXES: ttl html
