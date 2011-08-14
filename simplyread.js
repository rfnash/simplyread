/* See COPYING file for copyright, license and warranty details. */

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
	doc = (document.body === undefined)
	      ? window.content.document : document;
	
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
	
	if (biggest_num == 0) return 1;
	
	/* save and sanitise content of chosen tag */
	var fresh = doc.createElement("div");
	fresh.innerHTML = biggest_tag.innerHTML;
	fresh.innerHTML = fresh.innerHTML.replace(/<\/?font[^>]*>/g, "");
	fresh.innerHTML = fresh.innerHTML.replace(/style="[^"]*"/g, "");
	fresh.innerHTML = fresh.innerHTML.replace(/<\/?a[^>]*>/g, "");
	fresh.innerHTML = fresh.innerHTML.replace(/<\/?span[^>]*>/g, "");
	fresh.innerHTML = fresh.innerHTML.replace(/<style[^>]*>/g, "<style media=\"aural\">");
	
	for (var i = 0; i < doc.styleSheets.length; i++)
		doc.styleSheets[i].disabled = true;
	
	doc.body.innerHTML =
		"<style type=\"text/css\"> p{margin:0ex auto;}" +
		" p+p{text-indent:2em;} body {background-color:#cccccc}" +
		" img{display:block; max-width: 32em; padding:1em; margin:auto;}" +
		" h1,h2,h3,h4 {font-weight:normal}</style>" +
		"<div style=\"width:34em; padding:8em; padding-top:2em;" +
		" background-color:white; margin:auto; line-height:1.4;" +
		" text-align:justify; font-family:serif;" +
		" text-rendering:optimizeLegibility; hyphens:auto;\">" +
		"<h1 style=\"text-align:center;text-transform:uppercase\">"+doc.title+"</h1>" +
		"<hr style=\"width:6em; margin-top:2ex auto;\"/>" +
		fresh.innerHTML + "</div>";

	return 0;
}
