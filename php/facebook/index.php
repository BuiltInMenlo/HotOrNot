<?php session_start();

//header('Location: https://itunes.apple.com/us/app/picchallenge/id573754057?ls=1&mt=8');
//https://bit.ly/REvO8Q

//https://discover.getassembly.com/hotornot/facebook/
require './_db_open.php'; 

if (isset($_GET['cID'])) {
	$challenge_id = $_GET['cID'];
	
	$query = 'SELECT `status_id`, `subject_id`, `creator_img`, `challenger_img` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
	$challenge_obj = mysql_fetch_object(mysql_query($query));
	$status_id = $challenge_obj->status_id;
	$creator_img = $challenge_obj->creator_img . "_l.jpg";
	$challenger_img = $challenge_obj->challenger_img . "_l.jpg";
	
	$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
	$title = mysql_fetch_object(mysql_query($query))->title;
	
	$blurb = "PicChallenge - #challenge friends and strangers with photos, memes, quotes, and more!";
}


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
	<script>
		var oauth_url = 'https://www.facebook.com/dialog/oauth/';
		oauth_url += '?client_id=529054720443694';
		oauth_url += '&redirect_uri=' + encodeURIComponent('https://apps.facebook.com/pchallenge/');
		oauth_url += '&scope=publish_actions,status_update,publish_stream';

		window.top.location = oauth_url;
	</script>

	<h2>#<?php echo ($title); ?></h2>
	<hr />
	<p><?php echo ($blurb); ?></p>
	<center><p><img src="<?php echo ($creator_img); ?>" /><hr /><img src="<?php echo ($challenger_img); ?>" /></p></center>
  </body>  
</html>