<?php session_start();

require './_db_open.php'; 

$vote_id = 0;
if (isset($_POST['hidChallengeID']) && isset($_POST['hidFBID']) && isset($_POST['hidForCreator'])) {
	$challenge_id = $_POST['hidChallengeID'];
	
	// challenge info
	$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $challenge_id .';';
	$challenge_obj = mysql_fetch_object(mysql_query($query));
	
	$query = 'SELECT `id` FROM `tblUsers` WHERE `fb_id` = "'. $_POST['hidFBID'] .'";';
	$user_id = mysql_fetch_object(mysql_query($query))->id;
	
	$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_id .' AND `user_id` = '. $user_id .';';
	
	if (mysql_num_rows(mysql_query($query)) == 0) {
		if ($_POST['hidForCreator'] == "Y")
			$winningUser_id = $challenge_obj->creator_id;
		
		else
			$winningUser_id = $challenge_obj->challenger_id;
			
		$query = 'INSERT INTO `tblChallengeVotes` (';
		$query .= '`id`, `challenge_id`, `user_id`, `challenger_id`, `added`) VALUES (';
		$query .= 'NULL, "'. $challenge_id .'", "'. $user_id .'", "'. $winningUser_id .'", NOW());';
		$result = mysql_query($query);
		$vote_id = mysql_insert_id();
	
	} else {
		$vote_id = mysql_fetch_object(mysql_query($query))->id;
	}
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
		echo ("vote_id:[". $vote_id ."]<br />\n");
	?>
	
	<?php $url = "./index2.php?submit=1&cID=". $challenge_id; ?>
	<script>//location.href = "<?php echo ($url); ?>";</script>
  </body>  
</html>