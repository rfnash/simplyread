/* See COPYING file for copyright, license and warranty details. */

function simplyread_viable() {
	var doc;
	doc = (document.body === undefined)
	      ? window.content.document : document;
	return doc.getElementsByTagName("p").length;
}
