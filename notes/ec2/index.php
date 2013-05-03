<?php session_start();

//header('Location: https://itunes.apple.com/us/app/picchallenge/id573754057?ls=1&mt=8');

require './_db_open.php'; 

if (isset($_GET['cID'])) {
	$challenge_id = $_GET['cID'];
	
	$query = 'SELECT `subject_id`, `creator_img` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
	$img_url = mysql_fetch_object(mysql_query($query))->img_url . "_l.jpg";
	
	$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $row->subject_id .';';
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
    <meta property="og:image"  content="<?php echo ($img_url); ?>" /> 
    <meta property="og:description" content="<?php echo ($blurb); ?>" />
	
	<title><?php echo ($title); ?></title>
  </head>

  <body>
	<h2><?php echo ($title); ?></h2>
	<hr />
	<p><?php echo ($blurb); ?></p>
	<p><img src="<?php echo ($img_url); ?>" /></p>	
  </body>  
</html>