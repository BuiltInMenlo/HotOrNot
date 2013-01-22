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

$id_arr = array();
$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 4 ORDER BY `added`;';
$result = mysql_query($query);

while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	array_push($id_arr, $row['id']);
}

$_SESSION['challengeIDs'] = $id_arr;
$id_arr = $_SESSION['challengeIDs'];

$query = 'SELECT `id` FROM `tblChallenges` ORDER BY `added` DESC LIMIT 1;';
$lastChallenge_id = end(array_values($id_arr));
	
if (!isset($_GET['cID'])) {
	$challenge_id = $lastChallenge_id;
	
} else {
	$challenge_id = $_GET['cID'];
}

$ind = 0;
foreach ($id_arr as $key => $val) {
	if ($val >= $challenge_id) {
		$ind = $key;
		break;
	}
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

$creatorImg_url = "https://graph.facebook.com/". $creator_obj->fb_id ."/picture?type=square";
if ($creator_obj->fb_id == "")
	$creatorImg_url = "https://s3.amazonaws.com/picchallenge/default_user.jpg";

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
	<script type="text/javascript">
		$(document).ready(function() {
			$("#frmVoteCreator").submit(function() { 			
				$.post("vote.php", $("#frmVoteCreator").serialize(), function(data) {
					//$("#results").html(data);
					$('body').addClass('voted');
					
					// Creator > Challenger
					if (data == "-1") {
						$('.photo_a').addClass('winner');
						$('.photo_b').addClass('loser');
					}
					// Creator < Challenger
					else if (data == "1") {
						$('.photo_a').addClass('loser');
						$('.photo_b').addClass('winner');
					}
					// Creator == Challenger
					else {
						
					}
     			});
				return false;
			});
			
			$("#frmVoteChallenger").submit(function() {
				$.post("vote.php", $("#frmVoteChallenger").serialize(), function(data) {
					//$("#results").html(data);
					$('body').addClass('voted');
					
					// Creator > Challenger
					if (data == "-1") {
						$('.photo_a').addClass('winner');
						$('.photo_b').addClass('loser');
					}
					// Creator < Challenger
					else if (data == "1") {
						$('.photo_a').addClass('loser');
						$('.photo_b').addClass('winner');
					}
					// Creator == Challenger
					else {
						
					}
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
	  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=112460075444320";
	  fjs.parentNode.insertBefore(js, fjs);
	}(document, 'script', 'facebook-jssdk'));</script>

	<header>
		<div id="header_content">
			<h1><a href="#">picChallenge</a></h1>
			<p class="app_store"><a href="http://bit.ly/REvO8Q"><img src="_assets/img/app_store.png" alt="Available on the App Store" /></a></p>
		</div>
	</header>
	
	<p class="download_app"><a href="http://bit.ly/REvO8Q">Download the Application Now!</a></p>
	
	<!-- Begin container -->
	<div id="container">
		
		<!-- Begin content -->
		<div class="content clearfix">
			
			<!-- Begin challenge_info -->
			<div class="challenge_info clearfix"><?php if ($creator_obj->fb_id != "" ) {?>
				<a href="https://www.facebook.com/profile.php?id=<?php echo ($creator_obj->fb_id); ?>" target="_blank"><img src="<?php echo ($creatorImg_url); ?>" alt="" border="0" /></a>
				<?php }?>
				<div class="description">
					<p><strong><?php if ($creator_obj->fb_id != "" ) {?><a href="https://www.facebook.com/profile.php?id=<?php echo ($creator_obj->fb_id); ?>" target="_blank"><?php }?><?php echo ($creator_obj->username); ?></a></strong> has challenged <strong><?php if ($challenger_obj->fb_id != "" ) {?><a href="https://www.facebook.com/profile.php?id=<?php echo ($challenger_obj->fb_id); ?>" target="_blank"><?php }?><?php echo ($challenger_obj->username); ?></a></strong> to a <em><?php echo ($subject); ?></em></p>
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
				<?php if ($ind < count($id_arr) - 1) {?><li class="prev"><a href="./index.php?cID=<?php echo ($id_arr[$ind+1]); ?>">Prev</a></li><?php } ?>
				<?php if ($ind > 0) {?><li class="next"><a href="./index.php?cID=<?php echo ($id_arr[$ind-1]); ?>">Next</a></li><?php } ?>
			</ul>
			<!-- End photo_nav -->
		</div>
		<!-- End content -->
		
		<fb:comments href="https://apps.facebook.com/pchallenge/?cID=<?php echo ($challenge_id);?>" width="320" num_posts="2"></fb:comments>
		
	</div>
	<!-- End container -->

	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
	<script>window.jQuery || document.write('<script src="_assets/js/jquery-1.8.1.min.js"><\/script>')</script>
	<script src="_assets/js/plugins.js"></script>
	<script src="_assets/js/main.js"></script>

</body>

</html>