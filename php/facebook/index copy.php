<?php session_start();

//header('Location: https://itunes.apple.com/us/app/picchallenge/id573754057?ls=1&mt=8');
//https://bit.ly/REvO8Q

//https://discover.getassembly.com/hotornot/facebook/
require './_db_open.php'; 

if (isset($_GET['cID'])) {
	$challenge_id = $_GET['cID'];
	
	/*
	$query = 'SELECT `subject_id`, `creator_img`, `challenger_img` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
	$challenge_obj = mysql_fetch_object(mysql_query($query));
	$creator_img = $challenge_obj->creator_img . "_l.jpg";
	$challenger_img = $challenge_obj->challenger_img . "_l.jpg";
	*/
	
	$query = 'SELECT `subject_id`, img_url FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
	$challenge_obj = mysql_fetch_object(mysql_query($query));
	$creator_img = $challenge_obj->img_url . "_l.jpg";
	
	$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
	$title = mysql_fetch_object(mysql_query($query))->title;
	
	$query = 'SELECT `url` FROM `tblChallengeImages` WHERE `challenge_id` = '. $challenge_id .';';
	$challenger_img = mysql_fetch_object(mysql_query($query))->url . "_l.jpg";	
}

$blurb = "PicChallenge - #challenge friends and strangers with photos, memes, quotes, and more!";

require './_db_close.php'; 

?>
 
<html>
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# pchallenge: http://ogp.me/ns/fb/pchallenge#">
    <meta property="fb:app_id" content="529054720443694" /> 
    <meta property="og:type"   content="pchallenge:challenge" /> 
    <meta property="og:url"    content="http://<?php echo ($_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI']); ?>" /> 
    <meta property="og:title"  content="<?php echo ($title); ?>" /> 
    <meta property="og:image"  content="<?php echo ($creator_img); ?>" /> 
    <meta property="og:description" content="<?php echo ($blurb); ?>" />
	
	<title>#<?php echo ($title); ?></title>
  </head>

  <body>
	<div id="fb-root"></div>
	<!-- <script src="http://connect.facebook.net/en_US/all.js"></script> -->
	
	<form id="frmSubmit" name="frmSubmit" method="post" action="./submit.php">
		<input id="hidFBID" name="hidFBID" type="hidden" value="" />
		<input id="hidUsername" name="hidUsername" type="hidden" value="" />
		<input id="hidGender" name="hidGender" type="hidden" value="" />
	</form>
		
	<script>
	function getQueryString() {
	  var result = {}, queryString = location.search.substring(1),
	      re = /([^&=]+)=([^&]*)/g, m;

	  while (m = re.exec(queryString)) {
	    result[decodeURIComponent(m[1])] = decodeURIComponent(m[2]);
	  }

	  return result;
	}

	function login() {
	    FB.login(function(response) {
	        if (response.authResponse) {
				testAPI();
	            // connected
	        } else {
	            // cancelled
	        }
	    });
	}
	
	function testAPI() {
	    console.log('Welcome!  Fetching your information.... ');
	    FB.api('/me', function(response) {
	        console.log('Good to see you, ' + response.name + '.');
			//alert ("YOU ARE: [" + response.id + "] '" + response.username + "' (" + response.gender + ") {" + getQueryString()["submit"] + "}");
			
			var frmSubmit = document.getElementById('frmSubmit');
			if (getQueryString()["submit"] != "1") {				
				frmSubmit.hidFBID.value = response.id;
				frmSubmit.hidUsername.value = response.username;
				frmSubmit.hidGender.value = response.gender.toUpperCase().charAt(0);
				
				if (getQueryString()["cID"] != undefined)
					frmSubmit.action = "./submit.php?cID=<?php echo ($_GET['cID']); ?>";
				
				frmSubmit.submit();
			}
	    });
	}
	
	  window.fbAsyncInit = function() {
	    // init the FB JS SDK
	    FB.init({
	      appId      : '529054720443694', // App ID from the App Dashboard
	      channelUrl : '//discover.getassembly.com/hotornot/facebook/channel.html', // Channel File for x-domain communication
	      status     : true, // check the login status upon init?
	      cookie     : true, // set sessions cookies to allow your server to access the session?
	      xfbml      : true  // parse XFBML tags on this page?
	    });

	    // Additional initialization code such as adding Event Listeners goes here
		FB.getLoginStatus(function(response) {
		  if (response.status === 'connected') {
			// connected
			//alert("CONNECTED");
			testAPI();
		  } else if (response.status === 'not_authorized') {
		    // not_authorized
			//alert ("NOT AUTHORIZED");
			login();
		  } else {
		    // not_logged_in
			//alert ("NOT LOGGED IN");
			login();
		  }
		 });
	  };

	  // Load the SDK's source Asynchronously
	  // Note that the debug version is being actively developed and might 
	  // contain some type checks that are overly strict. 
	  // Please report such bugs using the bugs tool.
	  (function(d, debug){
	     var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
	     if (d.getElementById(id)) {return;}
	     js = d.createElement('script'); js.id = id; js.async = true;
	     js.src = "//connect.facebook.net/en_US/all" + (debug ? "/debug" : "") + ".js";
	     ref.parentNode.insertBefore(js, ref);
	   }(document, /*debug*/ false));
	</script>
    
	<?php if (isset($_GET['cID'])) {
		//echo ("<h2>#". $title ."</h2>\n");
		//echo ("<hr />\n");
		//echo ("<p>". $blurb ."</p>\n");
		//echo ("<center><p><img src='". $creator_img ."' /><hr /><img src='". $challenger_img ."' /></p></center>\n");
		echo ("<center>\n");
		echo ("<a href='http://bit.ly/VukhMo' target='_blank'><img src='./images/header.jpg'></img></a><br /><br />");
		echo ("<a href='http://bit.ly/VukhMo' target='_blank'><img src='./images/badge.png'></img></a>");
		echo ("</center>\n");
	
	} else { ?>
		<center>
			<a href="http://bit.ly/VukhMo" target="_blank"><img src="./images/header.jpg"></img></a><br /><br />
			<a href="http://bit.ly/VukhMo" target="_blank"><img src="./images/badge.png"></img></a>
		</center>
	<?php } ?>
  </body>  
</html>