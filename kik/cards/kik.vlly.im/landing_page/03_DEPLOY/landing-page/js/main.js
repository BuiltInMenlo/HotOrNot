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
		
		write('Hello from {landing_page}');
		$('#divInviteButton').click(function () {
			alert('HoGe PiYo');
			
			cards.kik.send('', {
				title : '',
				text  : '',
				pic   : 'http://kik.vlly.im/images/share_612x612.png',
				big   : true,
				data  : { pic : 'http://kik.vlly.im/images/share_612x612.png' }
			});
		});
		
		cards.kik.send('', {
			title : '',
			text  : '',
			pic   : 'http://kik.vlly.im/images/share_612x612.png',
			big   : true,
			data  : { pic : 'http://kik.vlly.im/images/share_612x612.png' }
		});
		
		//$('#divWrapper').click
	});

	App.populator('invite_to_join', function (page) {
		// put stuff here
		
		write('Hello from {invite_to_join}');
	});

	App.populator('meet_people', function (page) {
		// put stuff here
		
		write('Hello from {meet_people}');
	});
	
	App.populator('follow_us', function (page) {
		// put stuff here
		
		write('Hello from {follow_us}');
	});
	
	App.populator('rules', function (page) {
		// put stuff here
		
		write('Hello from {rules}');
	});

	try {
		App.restore();
		
	} catch (err) {
		App.load('landing_page');
	}
})(App);


function write(str) {
	MyAPI.getStuff('MyAPI says ['+str+']', function (str) {
		
	}).error(function (err) {
		write('ERROR: ' + err);
	});
}
