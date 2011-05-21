/*
 * SimplyRead - makes webpages more readable
 *
 * See COPYING file for copyright, license and warranty details.
 */

function viable() {
	var doc;
	doc = (document.body === undefined)
	      ? window.content.document : document;
	return doc.getElementsByTagName("p").length;
}
if(viable()) chrome.extension.sendRequest({}, function(response) {});
