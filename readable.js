/*
 * Readable - makes webpages more readable
 *
 * See COPYING file for copyright, license and warranty details.
 */

if(document.readable_original === undefined) document.readable_original = false;

function readable()
{
	/* count the number of <p> tags that are direct children of parenttag */
	function count_p(parenttag)
	{
		var n = 0;
		var c = parenttag.childNodes;
		for (var i = 0; i < c.length; i++) {
			if (c[i].tagName == "p" || c[i].tagName == "P")
				n++;
		}
		return n;
	}
	
	/* if we're running from a browser extension, rather than a page */
	if(document == undefined)
		var document = window.content.document;
	
	/* if readable_original is set, then the readable version is currently active,
	 * so switch to the readable_original html */
	if (document.readable_original) {
		document.body.innerHTML = document.readable_original;
		for (var i = 0; i < document.styleSheets.length; i++)
			document.styleSheets[i].disabled = false;
		document.readable_original = false
		return 0;
	}
	
	document.readable_original = document.body.innerHTML;
	
	var biggest_num = 0;
	var biggest_tag;
	
	/* search for tag with most direct children <p> tags */
	var t = document.getElementsByTagName("*");
	for (var i = 0; i < t.length; i++) {
		var p_num = count_p(t[i]);
		if (p_num > biggest_num) {
			biggest_num = p_num;
			biggest_tag = t[i];
		}
	}
	
	if (biggest_num == 0) {
		alert("Can't find any content");
		return 1;
	}
	
	/* save and sanitise content of chosen tag */
	var fresh = document.createElement("div");
	fresh.innerHTML = biggest_tag.innerHTML;
	fresh.innerHTML = fresh.innerHTML.replace(/<\/?font[^>]*>/g, "");
	fresh.innerHTML = fresh.innerHTML.replace(/style="[^"]*"/g, "");
	fresh.innerHTML = fresh.innerHTML.replace(/<\/?a[^>]*>/g, "");
	
	for (var i = 0; i < document.styleSheets.length; i++)
		document.styleSheets[i].disabled = true;
	
	document.body.innerHTML =
		"<div style=\"width: 38em; margin: auto; text-align: justify;\">" +
		"<h1 style=\"text-align: center\">" + document.title + "</h1>" +
		fresh.innerHTML + "</div>";

	return 0;
}
