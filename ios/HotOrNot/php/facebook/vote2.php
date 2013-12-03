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
	
	if ($_POST['hidForCreator'] == "Y")
		$votes_arr['creator']++;
		
	else
		$votes_arr['challenger']++;
		
	
	echo ($votes_arr['creator'] ."|". $votes_arr['challenger']);
}

require './_db_close.php'; 

?>