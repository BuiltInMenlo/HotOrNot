<?php

$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot-dev') or die("Could not select database.");

// echo ("hidChallengeID:[". $_POST['hidChallengeID'] ."]<br />\n");
// echo ("hidVoterID:[". $_POST['hidVoterID'] ."]<br />\n");
// echo ("hidForCreator:[". $_POST['hidForCreator'] ."]<br />\n");

if (isset($_POST['hidChallengeID']) && isset($_POST['hidVoterID']) && isset($_POST['hidForCreator'])) {
	$query = 'SELECT * FROM `tblChallenges` WHERE `id` = "'. $_POST['hidChallengeID'] .'";';
	$challenge_obj = mysql_fetch_object(mysql_query($query));
	
	$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
	$subject_name = mysql_fetch_object(mysql_query($query))->title;
	
	$winningID = ($_POST['hidForCreator'] == 1) ? $challenge_obj->creator_id : $challenge_obj->challenger_id;
	
	$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $_POST['hidChallengeID'] .' AND `user_id` = '. $_POST['hidVoterID'] .';';
	$result = mysql_query($query);
	
	if (mysql_num_rows($result) == 0) {
		$query = 'INSERT INTO `tblChallengeVotes` (';
		$query .= '`id`, `challenge_id`, `user_id`, `challenger_id`, `added`) VALUES (';
		$query .= 'NULL, "'. $_POST['hidChallengeID'] .'", "'. $_POST['hidVoterID'] .'", "'. $winningID .'", NOW());';
		$result = mysql_query($query);
		$vote_id = mysql_insert_id();
		
		$score_arr = array('creator' => 0, 'challenger' => 0);
		$query = 'SELECT `user_id`, `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $_POST['hidChallengeID'] .';';
		$vote_result = mysql_query($query);
		while ($vote_row = mysql_fetch_array($vote_result, MYSQL_BOTH)) {			
			if ($vote_row['challenger_id'] == $challenge_obj->creator_id)
				$score_arr['creator']++;						
			else
				$score_arr['challenger']++;
		}
		
		$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $_POST['hidVoterID'] .';';
		$voter_name = mysql_fetch_object(mysql_query($query))->username;
		
		
		$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = '. $winningID .';';
		$winningUser_obj = mysql_fetch_object(mysql_query($query));
		
		// if ($winningUser_obj->notifications == "Y") {
		// 	$msg = ($_POST['hidForCreator'] == 1) ? '{"device_tokens": ["'. $winningUser_obj->device_token .'"], "type":"1", "aps": {"alert": "Your '. $subject_name .' challenge has received '. $score_arr['creator'] .' total upvotes!", "sound": "push_01.caf"}}' : '{"device_tokens": ["'. $winningUser_obj->device_token .'"], "type":"1", "aps": {"alert": "Your '. $subject_name .' challenge has received '. $score_arr['challenger'] .' total upvotes!", "sound": "push_01.caf"}}';
		// 	
		// 	$ch = curl_init();
		// 	curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
		// 	//curl_setopt($ch, CURLOPT_USERPWD, "qJAZs8c4RLquTcWKuL-gug:mbNYNOkaQ7CZJDypDsyjlQ"); // dev
		// 	curl_setopt($ch, CURLOPT_USERPWD, "MB38FktJS8242wzKOOvEFQ:2c_IIFqWQKCpW9rhYifZVw"); // live
		// 	curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
		// 	curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
		// 	curl_setopt($ch, CURLOPT_POST, TRUE);
		// 	curl_setopt($ch, CURLOPT_POSTFIELDS, $msg);
		// 	$res = curl_exec($ch);
		// 	$err_no = curl_errno($ch);
		// 	$err_msg = curl_error($ch);
		// 	$header = curl_getinfo($ch);
		// 	curl_close($ch);
		// }
	
	} else 
		$vote_id = mysql_fetch_object($result)->id;
		
	$vote_cell = ($_POST['hidForCreator'] == 1) ? "0|" : "1|";
	$score_cell = ($_POST['hidForCreator'] == 1) ? $score_arr['creator'] : $score_arr['challenger'];
	echo ($_POST['hidChallengeID'] ."|". $vote_cell . $score_cell ."|casted by ". $voter_name);
}

if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>