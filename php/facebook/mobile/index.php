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

$query = 'SELECT `id` FROM `tblChallenges` ORDER BY `added` DESC LIMIT 1;';
$lastChallenge_id = mysql_fetch_object(mysql_query($query))->id;
	
if (!isset($_GET['cID'])) {
	$challenge_id = $lastChallenge_id;
	
} else {
	$challenge_id = $_GET['cID'];
}
	
// challenge info
$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
$challenge_obj = mysql_fetch_object(mysql_query($query));
$creator_img = $challenge_obj->creator_img . "_l.jpg";
$challenger_img = $challenge_obj->challenger_img . "_l.jpg";

if ($challenger_img == "_l.jpg")
	$challenger_img = "_assets/img/delete_me_photo_1.jpg";

$isInactive = false;
if ($challenge_obj->status_id == "1" || $challenge_obj->status_id == "2" || $challenge_obj->status_id == "3" || $challenge_obj->status_id == "6" || $challenge_obj->status_id == "8")
	$isInactive = true;
	
// subject
$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
$subject = mysql_fetch_object(mysql_query($query))->title;

// creator
$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $challenge_obj->creator_id .';';
$creator_obj = mysql_fetch_object(mysql_query($query));

// challenger
$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $challenge_obj->challenger_id .';';
$challenger_obj = mysql_fetch_object(mysql_query($query));

if ($challenger_obj->username == "")
	$challenger_obj->username = "someone";

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
</head>

<body class="voted">
	<div id="fb-root"></div>
	<script>(function(d, s, id) {
	  var js, fjs = d.getElementsByTagName(s)[0];
	  if (d.getElementById(id)) return;
	  js = d.createElement(s); js.id = id;
	  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=112460075444320";
	  fjs.parentNode.insertBefore(js, fjs);
	}(document, 'script', 'facebook-jssdk'));</script>

	<header>
		<div id="header_content">
			<h1><a href="#">picChallenge</a></h1>
			<p class="app_store"><a href="http://itunes.apple.com/us/app/id573754057?mt=8"><img src="_assets/img/app_store.png" alt="Available on the App Store" /></a></p>
		</div>
	</header>
	
	<p class="download_app"><a href="http://itunes.apple.com/us/app/id573754057?mt=8">Download the Application Now!</a></p>
	
	<!-- Begin container -->
	<div id="container">
		
		<!-- Begin content -->
		<div class="content clearfix">
			
			<!-- Begin challenge_info -->
			<div class="challenge_info clearfix">
				<img src="https://graph.facebook.com/<?php echo ($creator_obj->fb_id); ?>/picture?type=square" alt="" />
				<div class="description">
					<p><strong><?php echo ($creator_obj->username); ?></strong> has challenged <strong><?php echo ($challenger_obj->username); ?></strong> to a <em><?php echo ($subject); ?></em></p>
					<h2><?php echo ($subject); ?></h2>
				</div>
			</div>
			<!-- End challenge_info -->
		
			<!-- Begin photo_container -->
			<div id="photo_container" class="clearfix">
				
				<table>
					<tr>
						<td><img src="<?php echo($creator_img); ?>" alt="" /></td>
						<td><?php if ($isInactive) { ?>Waiting to be challenged<?php } else { ?><img src="<?php echo($challenger_img); ?>" alt="" /><?php } ?></td>
					</tr>
				</table>
			
				<div class="lightning"></div>
			</div>
			<!-- End photo_container -->
			
			<div id="fb_like">
				<fb:like send="true" layout="button_count" width="150" show_faces="true"></fb:like>
			</div>
			
			<!-- Begin photo_nav -->
			<ul id="photo_nav">
				<li class="prev"><a href="./index.php?cID=<?php echo ($challenge_id-1); ?>">Prev</a></li>
				<?php if ($challenge_id != $lastChallenge_id) {?><li class="next"><a href="./index.php?cID=<?php echo ($challenge_id+1); ?>">Next</a></li><?php } ?>
			</ul>
			<!-- End photo_nav -->
		</div>
		<!-- End content -->
		
		<fb:comments href="https://discover.getassembly.com/hotornot/facebook/index.php?cID=<?php echo ($challenge_id);?>" width="320" num_posts="2"></fb:comments>
		
	</div>
	<!-- End container -->

	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
	<script>window.jQuery || document.write('<script src="_assets/js/jquery-1.8.1.min.js"><\/script>')</script>
	<script src="_assets/js/plugins.js"></script>
	<script src="_assets/js/main.js"></script>

</body>

</html>