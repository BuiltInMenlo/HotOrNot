(function (App) {
	App.populator('landing_page', function (page) {
		// put stuff here
		
		// var img_obj = document.createElement("img");
		// 	img_obj.setAttribute("src", "http://localhost:5000/images/alert.png");
		// 	img_obj.setAttribute("height", "44");
		// 	img_obj.setAttribute("width", "320");
		// 	
		// 	
		// write(img_obj);
		// var divBubble_obj = document.getElementById("divBubble");
		// 	divBubble_obj.appendChild(img_obj);
		// write(divBubble_obj);
		// 	
		// MyAPI.getStuff('Hello from [landing_page]', function (str) {
		// 	write(str);
		// 	
		// }).error(function (err) {
		// 	write('ERROR: ' + err);
		// });
	});

	App.populator('invite_to_join', function (page) {
		// put stuff here
		
		MyAPI.getStuff('Hello from [invite_to_join]', function (str) {
			write(str);
			
		}).error(function (err) {
			write('ERROR: ' + err);
		});
	});

	App.populator('meet_people', function (page) {
		// put stuff here
		
		MyAPI.getStuff('Hello from [meet_people]', function (str) {
			write(str);
			
		}).error(function (err) {
			write('ERROR: ' + err);
		});
	});
	
	App.populator('follow_us', function (page) {
		// put stuff here
		
		MyAPI.getStuff('Hello from [follow_us]', function (str) {
			write(str);
			
		}).error(function (err) {
			write('ERROR: ' + err);
		});
	});
	
	App.populator('rules', function (page) {
		// put stuff here
		
		MyAPI.getStuff('Hello from [rules]', function (str) {
			write(str);
			
		}).error(function (err) {
			write('ERROR: ' + err);
		});
	});

	try {
		App.restore();
		
	} catch (err) {
		App.load('landing_page');
	}
})(App);


function write(str) {
	MyAPI.getStuff('Hello from ['+str+']', function (str) {
		
	}).error(function (err) {
		write('ERROR: ' + err);
	});
}
