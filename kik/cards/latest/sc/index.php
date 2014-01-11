<!DOCTYPE HTML>
<html>
    <head>  
        <title>KikApp - Selfies</title>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-16">
		<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
		<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
		<meta name="apple-mobile-web-app-capable" content="yes" />
		<meta name="kik-prefer" content="true">
		<link rel="kik-icon" href="./images/ico_sc.png">
        <link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.2.2/css/bootstrap-combined.min.css" rel="stylesheet">
        <link href="./css/main2.css" type="text/css" rel="stylesheet" />
        
		<script src="http://cdn.kik.com/cards/0/cards.js"></script>
		<script src="http://zeptojs.com/zepto.min.js"></script>
		
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
		<script type="text/javascript" src="./js/jquery.touchSwipe.js"></script>
		<script type="text/javascript" src="./js/main.js"></script>
    </head>
    <body>
		<div class="container">
			
			<script id='code_1'>
				var decodeHtmlEntity = function(str) {
					return (str.replace(/&#(\d+);/g, function(match, dec) {
						return (String.fromCharCode(dec));
					}));
				};
			
				var encodeHtmlEntity = function(str) {
					var buf = [];
					for (var i=str.length-1; i>=0; i--) {
						buf.unshift(['&#', str[i].charCodeAt(), ';'].join(''));
					}
				
					return (buf.join(''));
				};
			
			
				var img_arr = {};
				var swipe_obj = {};
				
				var IMG_WIDTH = 320;
				var IMG_HEIGHT = 568;
				var img_ind = 0;
				var img_tot = 16;
				var speed = 32;
				var ease_mult = 0.005;
				var selfieUrl = "/api/challenges/getselfies";
				var randomUserUrl = "/api/users/randomkikuser";
				var createUserUrl = "/api/users/createkikuser";
				var logOpenUrl = "/api/users/logkikopen";
				var logSendUrl = "/api/users/logkiksend";
				var teamUrl = "/boot_shane.json";
		        REDIRECTED = {};


				var divImgs_obj;
				
				var swipeOptions = {
					triggerOnTouchEnd	: true,	
					swipeStatus			: swipeStatus,
					allowPageScroll		: "no",
					threshold			: 56		
				}
				
				var uni_char = "\u1F447";
				
				var shareImg_url="./images/share-03_612x612_im.png";
				shareImg_url="./images/appstore_512.png";
				shareImg_url="./images/image222.png";
				shareImg_url="./images/insta____99.png";
				shareImg_url="./images/Untitled-1.png";
				shareImg_url="./images/Kik.png";
				shareImg_url="./images/insta-RecoveredBccc.png";
				shareImg_url="./images/upload.png";
				shareImg_url="./images/large.jpg";
				shareImg_url="./images/avatar.png";
				shareImg_url="./images/smallThumb.png";
				shareImg_url="./images/smallThumbB.png";
				//shareImg_url="";
				
				var tapsIO_url = "http://taps.io/J0Ig";
				
				
				/**
				* Catch each phase of the swipe.
				* move : we drag the div.
				* cancel : we animate back to where we were
				* end : we animate to the next image
				*/			
				
				/*** VERTICAL **** */
				function swipeStatus(event, phase, direction, distance) {
					//If we are moving before swipe, and we are going Lor R in X mode, or U or D in Y mode then drag.
					if (phase=="move") {
						var duration = 0;
						
						if (direction == "up")
							scrollImages((IMG_HEIGHT * img_ind) + distance, duration, true);
						
						else if (direction == "down")
							scrollImages((IMG_HEIGHT * img_ind) - distance, duration, true);
					}
					
					else if (phase == "cancel") {
						if (direction == "up")
							scrollImages(IMG_HEIGHT * img_ind, speed, true);
					}		
					
					else if (phase =="end") {
						if (direction == "down")
							previousImage(true)
							
						else if (direction == "up")			
							nextImage(true)
					}
				}

				/**
				
				*/
				
				function getCardTitle(){
					var titles = [
						'lol, KikSelfiesApp',
						'Did you see this app?',
						'LOL >> KikSelfiesApp',
						'Shoutout from...',
						'Want to join?',
						'Love selfies?',
						'Selfie queens LOL',
						'Have this app?',
						'Download this now!!',
						'trade selfies?',
						'KikSelfiesApp rules ',
						'GET THIS NOW!!',
						'Love ur profile pic',
						'u have been invited to',
						'Selfie shoutout',
						'Want this app?',
						'Best free selfie app',
						'Trade pics?',
						'Did you get this?',
						'have this yet?',
						'Are you on...',
						'r u on KikSelfiesApp?',
						'What is your selfie id?',
						'KikSelfiesApp username?',
						'have this yet?',
						'Selfies for days :)',
						'KikSelfiesApp!!!',
						'Best selfie app ever',
						'SelfieFamous?',
						'Want a shoutout?'
					];
					
					var title = titles[ parseInt( Math.random() * titles.length ) ];
					return title;
				}

				function getCardBody(){
					var msgs = [
						'trade selfies with me?',
						'this app is cute :) lol',
						'Would rule if you got this app!',
						'Can you help me with likes?',
						'why did you send me this?',
						'this app rules :)',
						'they made a club!! your in?',
						'are you in the club yet?',
						'HMU, shoutouts on KikSelfiesApp',
						'u invite me to KikSelfiesApp?',
						'cute pics :) KikSelfiesApp me?',
						'lots of cute selfies here :)',
						'I AM A SELFIE QUEEN :)',
						'did you see this app OMG!! lol',
						'da bomb for selfies :)',
						'soooo love this app :)',
						'ur cute want to trade on KikSelfiesApp',
						'KikSelfiesApp invite only',
						'Celebs are joining now too',
						'KikSelfiesApp YES! finally :)',
						'So many cute selfies here ...',
						'IN DA CLUB lol the KikSelfiesApp',
						"I can't wait to share this app at school",
						'wanna KikSelfiesApp me?',
						'Reply and like my selfies on KikSelfiesApp :)',
						'Do you have this app yet?',
						'KikSelfiesApp 4 DAYZ :)',
						'OMG, this is so cute.. this app :)',
						'KikSelfiesApp hmu up there :)',
						'Get the app for free now, lol',
					];
					var msg = msgs[ parseInt( Math.random() * msgs.length ) ];
					return msg;
				}

				function previousImage(isVertical) {
					img_ind = Math.max(img_ind - 1, 0);
					//$('#divDebug').text("previousImage -> img_ind:["+ img_ind +"]");
					
					scrollImages(IMG_HEIGHT * img_ind, speed, isVertical);
				}
			
				function nextImage(isVertical) {
					img_ind = Math.min(img_ind + 1, img_tot - 1);
					//$('#divDebug').text("nextImage -> img_ind:["+ img_ind +"]");
					
					scrollImages(IMG_HEIGHT * img_ind, speed, isVertical);
				}
				
				
				/**
				* Manually update the position of the imgs on drag
				*/
				function scrollImages(distance, duration, isVertical) {
					divImgs_obj.css("-webkit-transition-duration", (duration * ease_mult).toFixed(1) +"s");
					
					//inverse the number we set in the css
					var value = ((distance < 0) ? "" : "-") + Math.abs(distance).toString();
					var trans_coords = (isVertical) ? "0px,"+ value +"px,0px" : value +"px,0px,0px"
					divImgs_obj.css("-webkit-transform", "translate3d("+ trans_coords +")");
				}
				
				function sendCardToUser(title_str, msg_str, img_url, username, isLarge) {
					//$('#divSendto').text(username);
					var logData = {
				        source: KIKUSER.username,
				        target: username
					}
					logSend( logData );
					title_str = (typeof title_str !== 'undefined' || title_str.length == 0) ? title_str : '';
					msg_str = (typeof msg_str !== 'undefined' || msg_str.length == 0) ? msg_str : '';
					img_url = (typeof img_url !== 'undefined' || img_url.length == 0) ? img_url : '';
					isLarge = (typeof isLarge !== 'undefined') ? isLarge : false;
					
					isLarge = (title_str == '');
					try{
						console.log("++++++++++++++++++++++++++++++++++++++++++++++++++ in send");
						cards.kik.send(username, {
							title : title_str,
							text  : msg_str,
							big   : isLarge,
							pic   : img_url,
							data  : logData
						});
					} catch(err){
					    console.log( err );
					}

					//title_str = (title_str.length == 0) ? ' ' : title_str;
					//msg_str = (msg_str.length == 0) ? ' ' : msg_str;
				}
				
				function goPickerWithImage() {
					cards.kik.pickUsers(function (users) {
						if (!users) // action was cancelled by user
							return;

						users.forEach(function (user) {
							usernames += user.username + ', ';
						});
					});
				}
				
				var removeSelfie = function(){
				    var selfie = null;
					if(img_tot > 0 ){
						var imgToRem = divImgs_obj.get(0).getElementsByTagName('img')[ img_ind ];
						if(imgToRem){
						    selfie = img_arr[img_ind];
							imgToRem.remove();
							img_arr.splice(img_ind,1);
							img_tot--;
							img_ind = Math.min(img_ind, img_tot - 1);
							if( img_ind >= 0 && img_ind == (img_tot - 1) ){
								scrollImages(IMG_HEIGHT * img_ind, speed, true);
							} else if(img_ind < 0) {
							    refreshSelfies();
							}
						}
					}
					return selfie;
				}
				
				function addSelfieToCookie( selfie ){
				    var name = 'selfies_seen';
				    var cookieVal = getCookie(name);
				    if( cookieVal === null ){
				        cookieVal = '';
				    }
				    cookieVal += selfie.id + ',';
				    var expiresDate = new Date(new Date().getTime() + (365 * 86400 * 1000));
				    createCookie( name, cookieVal, expiresDate, '/' );
				}
				
				function createCookie(name, value, expires, path, domain) {
				    var cookie = name + "=" + escape(value) + ";";
				   
				    if (expires) {
				      // If it's a date
				      if(expires instanceof Date) {
				        // If it isn't a valid date
				        if (isNaN(expires.getTime()))
				         expires = new Date();
				      }
				      else
				        expires = new Date(new Date().getTime() + parseInt(expires) * 1000 * 60 * 60 * 24 * 7);
				   
				      cookie += "expires=" + expires.toGMTString() + ";";
				    }
				   
				    if (path)
				      cookie += "path=" + path + ";";
				    if (domain)
				      cookie += "domain=" + domain + ";";
				   
				    //console.log(cookie, name, value, expires, path, domain);
				    document.cookie = cookie;
				}
				
				function getCookie(name) {
				    name = name.trim();
				    var regexp = new RegExp(name +"=(.*?)(;|$)");
				    var result = regexp.exec(document.cookie);
				    return (result === null) ? null : unescape(result[1]);
				}
				
				function deleteCookie(name, path, domain) {
				    // If the cookie exists
				    if (getCookie(name))
				      createCookie(name, "", -1, path, domain);
				}
				
				function createUser( user ){
				    var successFunc = function( result ){
				        console.log( result );
				    }
				    jQuery.ajax({
				         url:    createUserUrl,
				         success: successFunc,
				         type: 'POST',
				         data: user
				    });
				}

				function logSend( logData ){
				    var successFunc = function( result ){
				        console.log( result );
				    }
				    jQuery.ajax({
				         url:    logSendUrl,
				         success: successFunc,
				         type: 'POST',
				         data: logData
				    });
				}

				function logOpen( logData ){
				    var successFunc = function( result ){
				        console.log( result );
				    }
				    jQuery.ajax({
				         url:    logOpenUrl,
				         success: successFunc,
				         type: 'POST',
				         data: logData
				    });
				}
				
				function getTeamMembers(  ){
				    TEAM = [];
				    var successFunc = function( result ){
				        if( result ){
						    console.log("============================================" + result );
				            TEAM = JSON.parse( result );
				        }
				    }
				    jQuery.ajax({
				         url:    teamUrl,
				         success: successFunc,
				         async: false,
				    });
				    console.log(TEAM + "_" + TEAM.length);
				}
        
				function startRandomConvo(){
				    var successFunc = function( result ){
				        var randUsername = result;
						sendCardToUser(getCardTitle(), getCardBody(), shareImg_url, randUsername);
				    }
				    jQuery.ajax({
				         url:    randomUserUrl,
				         success: successFunc,
				    });
				}
				
				function startConvo(){
					sendCardToUser(getCardTitle(), getCardBody(), shareImg_url, '');
				}
				
				function refreshSelfies(){
				    //handleSelfies([]);
				    //$.getJSON(selfieUrl, handleSelfies);
				}
				
				function doRedirect(){
				    clearInterval( REDIRECTED );
				    createCookie('sc_store_redirect','redirected');
			        location.href = 'http://taps.io/J0Ig';
				}
				
				function isTeamMember( name ){
				    var onTeam = false;
				    var len = TEAM.length;
				    for( var n = 0; n < len; n++ ){
						if( name == TEAM[n] ){
						    onTeam = true;
						}
				    }
					return onTeam;
				}
				
				function hasRedirected(  ){
				    return getCookie('sc_store_redirect');
				}

				function handleSelfies(result, user) {
					img_arr = Array();
					img_ind = 0;
					var len = result.length;
					for( n = 0; n < len; n++ ){
					    var selfie = result[n];
					    
					    var imgUrl = selfie.creator.img.replace('.jpg', '');
					    imgUrl = imgUrl.replace('Large_640x1136', '');
					    imgUrl += 'Large_640x1136.jpg';
					    
					    var title = imgUrl.replace('.jpg', '');
					    title = title.replace(/http(s*):\/\/[^\/]+\//, '');
					    
					    img_arr[n] = {
					        "id" : selfie.creator.id,
					    	"title": title,
					    	"url": imgUrl,
					    };
					}
					
				    img_arr = [{
					        "id" : 'tyu',
					    	"title": 'wheeee',
					    	"url": './images/bgApp.jpg',
				    }];
					
					img_tot = img_arr.length;

					if( divImgs_obj ){
						var imgs = divImgs_obj.get(0).getElementsByTagName('img');
						for( var n = 0; n < imgs.length; n++ ){
						    imgs[n].remove();
						}
					}
					
					divImgs_obj = $('#divImgs');
					divImgs_obj.css("height", (img_tot * IMG_HEIGHT) +'px');
					$('#txtDebug').append("\n" + img_arr.length +"\n");
					
					divImgs_obj.hide();
					for (var i=0; i< img_arr.length; i++){
					    if( isTeamMember( KIKUSER.username ) ){
						    divImgs_obj.append("\n\t\t\t\t\t\t<img src='"+ img_arr[i]['url'] +"' width='"+ IMG_WIDTH +"' height='"+ IMG_HEIGHT +"' />");
					    } else {
						    divImgs_obj.append("\n\t\t\t\t\t\t<a href='http://taps.io/J0Ig'><img src='"+ img_arr[i]['url'] +"' width='"+ IMG_WIDTH +"' height='"+ IMG_HEIGHT +"' /></a>");
					    }
					}
					divImgs_obj.show();

				    console.log("++++++++++++++APPENDING+++++++++++++++++");
					var button0 = '<a href="http://taps.io/J0Ig"><img id="imgBtnDownld" src="./images/downloadButton_im.png"/></a>';
				    var button1 = '<img id="imgBtnUp" src="./images/shareButton.png"/>';
				    var button2 = '<img id="imgBtnDn" src="./images/randomButton_im.png"/>';
				    $('#divButtonHolder').append( button0 );
				    $('#divButtonHolder').append( button1 );
				    if( isTeamMember( KIKUSER.username ) ){
				    	$('#divButtonHolder').append( button2 );
       				}
				    
					$('#imgBtnDn').mousedown(function () {
						$("#imgBtnDn").attr('src', "./images/randomButton_im.png");
						startRandomConvo();
						return (false);
					});
					
					$('#imgBtnDn').mouseup(function () {
						$("#imgBtnDn").attr('src', "./images/randomButton_im.png");
						return (false);
					});
					
					$('#imgBtnUp').mousedown(function () {
						$("#imgBtnUp").attr('src', "./images/shareButton.png");
						startConvo();							
						return (false);
					});

					$('#imgBtnUp').mouseup(function () {
						$("#imgBtnUp").attr('src', "./images/shareButton.png");
						return (false);
					});
					
					//console.log( "user oooh = " + user.username );
					if( !user || ( !isTeamMember( user.username ) && !hasRedirected() ) )
					{
						REDIRECTED = setInterval("doRedirect( );",1000);
					}
				}
				
				$(function () {
					(function() {
						$('#divDebug').hide();
						$('#divAppStoreBadge').hide();
						
						//$.getJSON(selfieUrl, handleSelfies);
						
						// |\}._.-+-._.+-._.-+-._.-+-._.-+-._.-\'/)»
						
						var vp_width = $(window).width();
						var vp_height = $(window).height();
						
						
						var offset_bott = 20;

						$('#divAppStoreBadge').css({
						  bottom: (offset_bott + (vp_height - 502)).toString() +'px'
						});
						
						divImgs_obj = $('#divImgs');
						divImgs_obj.swipe(swipeOptions);

						if( cards.kik ){
							cards.ready(function () {
							    getTeamMembers();
						        //createUser( user );
								if (cards.kik.message) {// web app was opened from Kik message
									logOpen(cards.kik.message);
								}
								cards.kik.getUser(function (user) {
								    if ( !user ) {
								        // user denied access to their information
								        KIKUSER = {
								        	username:"maddielux19",
								        	thumbnail:'',
								        	pic:'',
								        	firstName:'Maddie',
								        	lastName:'Lux'
								        };
								    } else {
								        createUser( user );
								        KIKUSER = user;
								        if( user.thumbnail ){
									        shareImg_url = user.thumbnail;
								        }
								    }
									handleSelfies([],user);
								});
							});
						} else {
							handleSelfies([],null);
						}
					})();
				});
			</script>
			
			<div id="divContent">
				<div id="divImageHolder">
					<div id="divImgs"></div>
				</div>
				<div id="divButtonHolder">
				</div>
				<div id="divAppStoreBadge">
				<a href="http://taps.io/J0Ig">
					<img src="./images/badge.png" width="129" height="44" alt="Get it on the App Store!" border="0" />
				</a>
				</div>
			</div>
		</div>
		<div id="divDebug"><textarea id="txtDebug" cols="45" rows="8"></textarea></div>
		
		<script>
			(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
			(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
			m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
			})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

			if (cards.kik) {
				cards.metrics.enableGoogleAnalytics();
			}
		</script>
		
		<div id="divChars">
			<!-- // U+00020 [ ] (Non-breaking space) -->
			<input type="hidden" id="hidUTF_nbsp" value="&nbsp;" />
			
			<!-- // U+1F48B [������] (Kiss Mark) // -->
			<input type="hidden" id="hidUTF_128071" value="&#128071;" />
			<input type="hidden" id="hidUTF_1F447" value="&#x1F447;" />
			<input type="hidden" id="hidUTFChar_hex" value="0xF09F9187" />
			
			<!-- // U+1F447 [������] (White Down Pointing Backhand Index) // -->
			<input type="hidden" id="hidUTF_128139" value="&#128139;" />
			<input type="hidden" id="hidUTF_1F48B" value="&#x1F48B;" />
		</div>
		
   </body>
</html>
