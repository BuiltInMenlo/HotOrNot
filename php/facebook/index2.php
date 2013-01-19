<?php session_start();

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
	
	$votes_tot = $votes_arr['creator'] + $votes_arr['challenger'];
	$title = $creator_obj->username ." and ". $challenger_obj->username ." are challenging to ". $subject;
}

require './_db_close.php';

?>

<!DOCTYPE html>

<html lang="en" xmlns:fb="http://ogp.me/ns/fb#">
<head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# pchallenge: http://ogp.me/ns/fb/pchallenge#">
	<meta charset="utf-8" />
	<meta name="description" content="goes_here" />	<!-- Set -->
	<meta property="fb:app_id" content="529054720443694" /> 
    <meta property="og:type"   content="pchallenge:challenge" /> 
    <meta property="og:url"    content="http://<?php echo ($_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI']); ?>" /> 
    <meta property="og:title"  content="<?php echo ($subject); ?>" /> 
    <meta property="og:image"  content="<?php echo ($creator_img); ?>" /> 
    <meta property="og:description" content="<?php echo ($title); ?>" />
	
	<title><?php echo ($subject); ?></title>
	
	<link rel="stylesheet" href="_assets/css/master.css" media="screen" />
	<!--[if IE]>
	<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->
	
	<script>
		function goVote(isCreator) {
			var frmVote = document.getElementById('frmVote');
			if (isCreator == 1)
				frmVote.hidForCreator.value = 'Y';
			
			else
				frmVote.hidForCreator.value = 'N';
			
			frmVote.submit();
		}
		
		function getQueryString() {
	  		var result = {}, queryString = location.search.substring(1),
	      	re = /([^&=]+)=([^&]*)/g, m;

	  		while (m = re.exec(queryString)) {
	    		result[decodeURIComponent(m[1])] = decodeURIComponent(m[2]);
	  		}

	  		return result;
		}
	</script>
	
	<script type="text/javascript" src="_assets/js/jquery-1.4.2.min.js"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$("#frmVoteCreator").submit(function() { 			
				$.post("vote.php", $("#frmVoteCreator").serialize(), function(data) {
					$("#results").html(data);
     			});
				return false;
			});
			
			$("#frmVoteChallenger").submit(function() {
				$.post("vote.php", $("#frmVoteChallenger").serialize(), function(data) {
					$("#results").html(data);
     			});
				return false;
			});
			
			$("#frmSignIn").submit(function() {
				alert ("SIGNIN");     			
				$.post("signin.php", $("#frmSignIn").serialize(), function(data) {
					$("#results").html(data);
     			});
				return false;
			});
			
			$("#frmSMS").submit(function() {
				alert ("SIGNIN");     			
				$.post("sms.php", $("#frmSMS").serialize(), function(data) {
					$("#results").html(data);
     			});
				return false;
			});
		});
	</script>
</head>

<body>
	<div id="fb-root"></div>
	<script>(function(d, s, id) {
	  var js, fjs = d.getElementsByTagName(s)[0];
	  if (d.getElementById(id)) return;
	  js = d.createElement(s); js.id = id;
	  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=529054720443694";
	  fjs.parentNode.insertBefore(js, fjs);
	}(document, 'script', 'facebook-jssdk'));</script>
	
	<script>
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
			
			var frmVoteCreator = document.getElementById('frmVoteCreator');
				frmVoteCreator.hidFBID.value = response.id;
				
			var frmVoteChallenger = document.getElementById('frmVoteChallenger');
				frmVoteChallenger.hidFBID.value = response.id;
			
			var frmSignIn = document.getElementById('frmSignIn');
				frmSignIn.hidFBID.value = response.id;
				frmSignIn.hidUsername.value = response.username;
				frmSignIn.hidGender.value = response.gender.toUpperCase().charAt(0);
				//frmSignIn.submit();
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
	</script>
	
	<header>
		<div id="header_content">
			<h1><a href="#">picChallenge</a></h1>
			<p class="app_store"><a href="#"><img src="_assets/img/app_store.png" alt="Available on the App Store" /></a></p>
		</div>
	</header>
	
	<form id="frmSignIn" name="frmSignIn">
		<input id="hidFBID" name="hidFBID" type="hidden" value="" />
		<input id="hidUsername" name="hidUsername" type="hidden" value="" />
		<input id="hidGender" name="hidGender" type="hidden" value="" />
	</form>
	
	<div id="results"></div>
	
	<form id="frmSMS" name="frmSMS">
		<input id="txtPhone1" name="txtPhone1" type="text" size="3" value="" />
		<input id="txtPhone2" name="txtPhone2" type="text" size="3" value="" />
		<input id="txtPhone3" name="txtPhone3" type="text" size="4" value="" />
		<input type="submit" />
	</form>

	<!-- Begin container -->
	<div id="container">
		
		<!-- Begin content -->
		<div class="content">
			
			<!-- Begin challenge_info -->
			<div class="challenge_info clearfix">
				<img src="https://graph.facebook.com/<?php echo ($creator_obj->fb_id); ?>/picture?type=square" width="50" height="50" alt="" />
				<div class="description">
					<p><strong><?php echo ($creator_obj->username); ?></strong> has challenged <strong><?php echo ($challenger_obj->username); ?></strong> to a <em><?php echo ($subject); ?></em></p>
					<h2><?php echo ($subject); ?></h2>
				</div>
				
				<p class="report"><a href="#">Report Abuse</a></p>
			</div>
			<!-- End challenge_info -->
		
			<!-- Begin photo_container -->
			<div id="photo_container" class="clearfix">
			
				<div class="photo photo_a">
					<img src="<?php echo($creator_img); ?>" width="356" height="356" alt="" />
					<form id="frmVoteCreator" name="frmVoteCreator">
						<input id="hidChallengeID" name="hidChallengeID" type="hidden" value="<?php echo ($challenge_id); ?>" />
						<input id="hidFBID" name="hidFBID" type="hidden" value="" />
						<input id="hidForCreator" name="hidForCreator" type="hidden" value="Y" />
						<input type="submit" />
					</form>
					<p class="vote"><a href="#" onclick="goVote(1)">Vote on this pic</a></p>
					<p class="vote_count"><?php echo ($votes_arr['creator']); ?></p>
					<p class="winning">Winning</p>
				</div>
			
				<div class="photo photo_b">
					<img src="<?php echo($challenger_img); ?>" width="356" height="356" alt="" />
					<form id="frmVoteChallenger" name="frmVoteChallenger">
						<input id="hidChallengeID" name="hidChallengeID" type="hidden" value="<?php echo ($challenge_id); ?>" />
						<input id="hidFBID" name="hidFBID" type="hidden" value="" />
						<input id="hidForCreator" name="hidForCreator" type="hidden" value="N" />
						<input type="submit" />
					</form>
					<p class="vote"><a href="#" onclick="goVote(0)">Vote on this pic</a></p>
					<p class="vote_count"><?php echo ($votes_arr['challenger']); ?></p>
				</div>
			
				<div class="lightning"></div>
			</div>
			<!-- End photo_container -->
			
			<h2 class="photo_challenge">Photo Challenge</h2>
			
			<fb:like send="true" width="450" show_faces="true"></fb:like>
			
			<!-- Begin photo_nav -->
			<ul id="photo_nav">
				<li class="prev"><a href="./index2.php?submit=1&cID=<?php echo ($challenge_id-1); ?>">Prev</a></li>
				<li class="next"><a href="./index2.php?submit=1&cID=<?php echo ($challenge_id+1); ?>">Next</a></li>
			</ul>
			<!-- End photo_nav -->
		</div>
		<!-- End content -->
		
		<fb:comments href="https://discover.getassembly.com/hotornot/facebook/index2.php?cID=<?php echo ($challenge_id);?>" width="753" num_posts="2"></fb:comments>
		
	</div>
	<!-- End container -->

	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
	<script>window.jQuery || document.write('<script src="_assets/js/jquery-1.8.1.min.js"><\/script>')</script>
	<script src="_assets/js/plugins.js"></script>
	<script src="_assets/js/main.js"></script>

</body>

</html>