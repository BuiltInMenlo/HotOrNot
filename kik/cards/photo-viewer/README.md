PhotoViewer
===========

PhotoViewer is an aggressively optimized and thouroghly tested photo viewer
library for [App.js](https://github.com/kikinteractive/app).
It works across modern mobile browsers (Android 2.2+, iOS 5+).

Try the demo (preferably on your phone, it's easy to be
smooth on desktop): http://code.kik.com/photo-viewer/demos/index.html

PhotoViewer is suitable for photo galleries of any size. Under the hood, it
only ever handles a maximum of three photos at once, meaning you get the same
performance regardless of how large your album is.

__Download__ (minified): [photo-viewer.js](http://cdn.kik.com/photo-viewer/1/photo-viewer.js)


Usage
-----

For basic usage, just give the PhotoViewer your page, and some urls to munch on:

	App.populator('viewer', function (page, data) {
		var photoViewer = new PhotoViewer(page, data.urls);
	});

You can listen to events:

	photoViewer.on('flip', function (page) {
		data.index = page;
		App.saveStack();
	});

And customize the options to your needs:

	var photoViewer = new PhotoViewer(page, urls, {
		// Automatically update the page title as the user swipes through
		// photos?
		automaticTitles: true,
		// Hide the titlebar automatically, using whichever gestures are
		// recognized on the device's native photo viewer.
		autoHideTitle: true,
		// An element used as a placeholder while photos are loading.
		// A duplicate is made each time it is used.
		loadingElm: defaultLoadingElm,
		// Photo index to start at.
		startAt: 0,
	});

A complete example of a typical PhotoViewer user:

	App.populator('viewer', function (page, data) {
		var photoViewer = new PhotoViewer(page, data.urls, {
			startAt: parstInt(data.index, 10),
		});
		photoViewer.on('flip', function (page) {
			data.index = page;
			App.saveStack();
		});
	});
	App.load('viewer', {
		urls: ['funny-cat-picture.jpg', 'funny-lolcat.jpg'],
		index: 1,
	});
