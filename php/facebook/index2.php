<?php session_start();

//header('Location: https://itunes.apple.com/us/app/picchallenge/id573754057?ls=1&mt=8');
//https://bit.ly/REvO8Q

//https://discover.getassembly.com/hotornot/facebook/
require './_db_open.php'; 

$title = "";
$creator_img = "";
$challenger_img = "";
$blurb = "PicChallenge - #challenge friends and strangers with photos, memes, quotes, and more!";
$testflight_url = "http://tflig.ht/W0E97T";

$isIpod = stripos($_SERVER['HTTP_USER_AGENT'], "iPod");
$isIphone = stripos($_SERVER['HTTP_USER_AGENT'], "iPhone");
$isOSX = stripos($_SERVER['HTTP_USER_AGENT'], "Macintosh");

if (isset($_GET['cID'])) {
	$challenge_id = $_GET['cID'];
	
	// challenge info
	$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
	$challenge_obj = mysql_fetch_object(mysql_query($query));
	$creator_img = $challenge_obj->creator_img . "_l.jpg";
	$challenger_img = $challenge_obj->challenger_img . "_l.jpg";
	
	// subject
	$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
	$subject = mysql_fetch_object(mysql_query($query))->title;
	
	// creator
	$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $challenge_obj->creator_id .';';
	$creator_obj = mysql_fetch_object(mysql_query($query));
	
	// challenger
	$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $challenge_obj->challenger_id .';';
	$challenger_obj = mysql_fetch_object(mysql_query($query));
	
	// votes
	$votes_arr = array('creator' => 0, 'challenger' => 0);
	$query = 'SELECT `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .';';
	$votes_result = mysql_query($query);
	
	while ($vote_row = mysql_fetch_array($votes_result, MYSQL_BOTH)) {										
		if ($vote_row['challenger_id'] == $challenge_obj->creator_id)
			$votes_arr['creator']++;
			
		else
			$votes_arr['challenger']++;
	}
	
	$votes_tot = $votes_arr['creator'] + $votes_arr['challenger'];//mysql_num_rows(mysql_query($query));
	
	
	$title = $creator_obj->username ." and ". $challenger_obj->username ." are challenging to ". $subject;
}

require './_db_close.php'; 

?>
 
<html>
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# pchallenge: http://ogp.me/ns/fb/pchallenge#">
    <meta property="fb:app_id" content="529054720443694" /> 
    <meta property="og:type"   content="pchallenge:challenge" /> 
    <meta property="og:url"    content="http://<?php echo ($_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI']); ?>" /> 
    <meta property="og:title"  content="<?php echo ($subject); ?>" /> 
    <meta property="og:image"  content="<?php echo ($creator_img); ?>" /> 
    <meta property="og:description" content="<?php echo ($title); ?>" />
	
	<title><?php echo ($subject); ?></title>
	
	<script>
		function goVote(isCreator) {
			var frmVote = document.getElementById('frmVote');
			if (isCreator == 1)
				frmVote.hidForCreator.value = 'Y';
			
			else
				frmVote.hidForCreator.value = 'N';
			
			frmVote.submit();
		}
	</script>
  </head>

  <body>
	<div id="fb-root"></div>
	<form id="frmSubmit" name="frmSubmit" method="post" action="./submit2.php">
		<input id="hidFBID" name="hidFBID" type="hidden" value="" />
		<input id="hidUsername" name="hidUsername" type="hidden" value="" />
		<input id="hidGender" name="hidGender" type="hidden" value="" />
	</form>
	
	<form id="frmVote" name="frmVote" method="post" action="./vote.php">
		<input id="hidFBID" name="hidFBID" type="hidden" value="" />
		<input id="hidChallengeID" name="hidChallengeID" type="hidden" value="<?php echo ($challenge_id); ?>" />
		<input id="hidForCreator" name="hidForCreator" type="hidden" value="" />
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
			
			var frmVote = document.getElementById('frmVote');
				frmVote.hidFBID.value = response.id;
			
			var frmSubmit = document.getElementById('frmSubmit');
			if (getQueryString()["submit"] != "1") {				
				frmSubmit.hidFBID.value = response.id;
				frmSubmit.hidUsername.value = response.username;
				frmSubmit.hidGender.value = response.gender.toUpperCase().charAt(0);
				
				if (getQueryString()["cID"] != undefined)
					frmSubmit.action = "./submit2.php?cID=<?php echo ($_GET['cID']); ?>";
				
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
    
	<?php if (isset($_GET['cID']) && $isOSX) { ?>
		<table cellpadding='0' cellspacing='0' border='0' width='1224'>
			<tr><td colspan='2'><h2><?php echo ($title); ?></h2><hr width='90%' /></td></tr>
			<tr>
				<td align='center'><a href='#' onclick='goVote(1)'><img src='<?php echo($creator_img); ?>' width='612' height='612' alt='' border='' /></a><br /><?php echo ($votes_arr['creator']); ?></td>
				<td align='center'><a href='#' onclick='goVote(0)'><img src='<?php echo($challenger_img); ?>' width='612' height='612' alt='' border='' /></a><br /><?php echo ($votes_arr['challenger']); ?></td>
			</tr>
			<tr><td colspan='2'><hr width='90%' /></td></tr>
			<tr><td colspan='2'><?php echo ($votes_tot); ?> Votes</td></tr>
			<tr><td colspan='2' align='center'><a href='https://discover.getassembly.com/hotornot/facebook/index2.php?submit=1&cID=<?php echo ($challenge_id-1); ?>'>Prev</a> | <a href='https://discover.getassembly.com/hotornot/facebook/index2.php?submit=1&cID=<?php echo ($challenge_id+1); ?>'>Next</a></td></tr>
		</table>
		
		<div id="fb-root"></div>
      <script>
        // Load the SDK Asynchronously
        (function(d){
           var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
           if (d.getElementById(id)) {return;}
           js = d.createElement('script'); js.id = id; js.async = true;
           js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
           ref.parentNode.insertBefore(js, ref);
         }(document));
      </script>

      <div class="fb-like"></div>

	<script>(function(d, s, id) {
	  var js, fjs = d.getElementsByTagName(s)[0];
	  if (d.getElementById(id)) return;
	  js = d.createElement(s); js.id = id;
	  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=529054720443694";
	  fjs.parentNode.insertBefore(js, fjs);
	}(document, 'script', 'facebook-jssdk'));</script>
	<div class="fb-comments" data-href="https://discover.getassembly.com/hotornot/facebook/index2.php?cID=<?php echo ($challenge_id);?>" data-width="1224" data-num-posts="10"></div>
	<?php
	} else { ?>
		<center>
			<a href="http://bit.ly/VukhMo" target="_blank"><img src="./images/header.jpg"></img></a><br /><br />
			<a href="http://bit.ly/VukhMo" target="_blank"><img src="./images/badge.png"></img></a>
		</center>
	<?php } ?>
  </body>  
</html>