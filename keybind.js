/* See COPYING file for copyright, license and warranty details. */

(function() {
	document.addEventListener('keydown', keybind, false);
})();

function keybind(e) {
	if(e.keyCode == 82 && e.ctrlKey && e.altKey) simplyread();
}
