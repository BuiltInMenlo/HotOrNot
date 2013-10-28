// Avoid `console` errors in browsers that lack a console.
if (!(window.console && console.log)) {
	(function() {
		var noop = function() {};
		var methods = ['assert', 'clear', 'count', 'debug', 'dir', 'dirxml', 'error', 'exception', 'group', 'groupCollapsed', 'groupEnd', 'info', 'log', 'markTimeline', 'profile', 'profileEnd', 'markTimeline', 'table', 'time', 'timeEnd', 'timeStamp', 'trace', 'warn'];
		var length = methods.length;
		var console = window.console = {};
		while (length--) {
			console[methods[length]] = noop;
		}
	}());
}

// Place any jQuery/helper plugins in here.

/*
This clears out the "hint" in input fields. Replaces with the original hint if no text is entered.
Thanks to Jörn Zaefferer:
http://bassistance.de/2007/01/23/unobtrusive-clear-searchfield-on-focus/
*/
$.fn.clearField = function() {
	return this.addClass('hint-text').focus(function() {
		if( this.value == this.defaultValue ) {
			this.value = "";
      $(this).removeClass('hint-text');
		}
	}).blur(function() {
		if( !this.value.length ) {
			this.value = this.defaultValue;
      $(this).addClass('hint-text');
		}
	});
};



/*
Rollovers for the input type="image".
Thanks to Atlanta Jones:
http://www.atlantajones.com/2008/07/02/even-easier-jquery-rollovers/
*/
$.fn.rollOver = function() {
	// Set the original src
	rollsrc = $(this).attr("src");
	if (rollsrc) {
		rollON = rollsrc.replace('off', 'on');
		newImg = new Image(); // create new image obj
		$(newImg).attr("src", rollON); // set new obj's src
	}
	
	this.mouseover(function() {
		imgsrc = $(this).attr("src");
		if (typeof(imgsrc) != 'undefined') {
		imgsrcON = imgsrc.replace('off', 'on');
		$(this).attr("src", imgsrcON);
		}
	});

	// Handle mouseout
	this.mouseout(function(){
		if (typeof(imgsrc) != 'undefined') {
		$(this).attr("src", imgsrc);
		}
	});
};