<?php session_start();

require './_db_open.php'; 

if (isset($_GET['cID'])) {
	$challenge_id = $_GET['cID'];
	
	$query = 'SELECT `subject_id`, `img_url` FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
	$row = mysql_fetch_object(mysql_query($query));
	$img_url = $row->img_url;
	
	$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $row->subject_id .';';
	$row = mysql_fetch_object(mysql_query($query));	
	$title = $row->title;
	
	$blurb = "Formas humanitatis per seacula quarta decima et quinta decima. Adipiscing elit sed diam nonummy nibh euismod tincidunt ut laoreet dolore. Wisi enim ad minim veniam quis nostrud exerci. Esse molestie consequat, vel illum dolore eu feugiat nulla facilisis? Processus dynamicus qui sequitur mutationem consuetudium lectorum mirum est notare quam. Non habent claritatem insitam est usus legentis in iis, qui facit eorum claritatem Investigationes.";
}


require './_db_close.php'; ?>


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
<!--
	<script type="text/javascript">
      setTimeout(function() {window.location = "<?php echo ($url); ?>";}, 500);
    </script>
-->
  </body>  
</html>
