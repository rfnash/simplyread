function srviable() {
	document.getElementById("simplyread-btn").disabled = !simplyread_viable();
}
window.addEventListener("DOMContentLoaded", srviable, false);
gBrowser.tabContainer.addEventListener("TabSelect", srviable, false);
