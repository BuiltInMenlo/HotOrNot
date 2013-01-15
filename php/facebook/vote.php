<?php session_start();

require './_db_open.php'; 

if (isset($_POST['hidChallengeID']) && isset($_POST['hidFBID']) && isset($_POST['hidForCreator'])) {
	$challenge_id = $_POST['hidChallengeID'];
	
	// challenge info
	$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
	$challenge_obj = mysql_fetch_object(mysql_query($query));
	
	
}

require './_db_close.php'; 

?>
 
<html>  
  <head />
  <body>
	<?php
		echo ("hidChallengeID:[". $_POST['hidChallengeID'] ."]<br />\n");
		echo ("hidFBID:[". $_POST['hidFBID'] ."]<br />\n");
		echo ("hidForCreator:[". $_POST['hidForCreator'] ."]<br />\n");
	?>
	
	<?php $url = "./index2.php?submit=1&cID=". $challenge_id; ?>
	<script>location.href = "<?php echo ($url); ?>";</script>
  </body>  
</html>