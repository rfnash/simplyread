/*
 * See COPYING file for copyright, license and warranty details.
 */
(function() {
	document.addEventListener('keydown', keybind, false);
})();

function keybind(e) {
	if (e.keyIdentifier == "U+0052" && e.ctrlKey && e.altKey) // ctrl-alt-r
		simplyread();
}
