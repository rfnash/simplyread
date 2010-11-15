/*
 * SimplyRead - makes webpages more readable
 *
 * See COPYING file for copyright, license and warranty details.
 */

if(window.content && window.content.document.simplyread_original === undefined) window.content.document.simplyread_original = false;

function simplyread()
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
	
	var doc;
	if(document.body === undefined)
		doc = window.content.document;
	else
		doc = document;
	
	/* if simplyread_original is set, then the simplyread version is currently active,
	 * so switch to the simplyread_original html */
	if (doc.simplyread_original) {
		doc.body.innerHTML = doc.simplyread_original;
		for (var i = 0; i < doc.styleSheets.length; i++)
			doc.styleSheets[i].disabled = false;
		doc.simplyread_original = false
		return 0;
	}
	
	doc.simplyread_original = doc.body.innerHTML;
	
	var biggest_num = 0;
	var biggest_tag;
	
	/* search for tag with most direct children <p> tags */
	var t = doc.getElementsByTagName("*");
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
	var fresh = doc.createElement("div");
	fresh.innerHTML = biggest_tag.innerHTML;
	fresh.innerHTML = fresh.innerHTML.replace(/<\/?font[^>]*>/g, "");
	fresh.innerHTML = fresh.innerHTML.replace(/style="[^"]*"/g, "");
	fresh.innerHTML = fresh.innerHTML.replace(/<\/?a[^>]*>/g, "");
	
	for (var i = 0; i < doc.styleSheets.length; i++)
		doc.styleSheets[i].disabled = true;
	
	doc.body.innerHTML =
		"<div style=\"width:38em; margin:auto; text-align:justify; font-family:sans;\">" +
		"<h1 style=\"text-align: center\">" + doc.title + "</h1>" +
		fresh.innerHTML + "</div>";

	return 0;
}
