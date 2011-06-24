/* See COPYING file for copyright, license and warranty details. */

(function() {
	document.addEventListener('keydown', keybind, false);
})();

function keybind(e) {
	if(e.ctrlKey && e.altKey && String.fromCharCode(e.keyCode) == "R")
		simplyread();
}
