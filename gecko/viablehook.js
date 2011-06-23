function srviable() {
	document.getElementById("simplyread-btn").disabled = !simplyread-viable();
}
window.addEventListener("DOMContentLoaded", srviable, false);
gBrowser.tabContainer.addEventListener("TabSelect", srviable, false);
