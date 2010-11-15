(function() {
	stag = document.createElement("script");
	stag.src="file://./simplyread.js";
	document.body.appendChild(stag);
	window.alert('Click me quick'); // this seems to make simplyread.js register..
	simplyread();
	console.log(document.body.innerHTML);
})();
