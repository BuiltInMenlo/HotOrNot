<?php

$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot-dev') or die("Could not select database.");

$query = 'SELECT `id` FROM `tblChallenges` WHERE `status_id` = 4 ORDER BY `added` DESC LIMIT 200;';
$challenge_result = mysql_query($query);

$user_arr = array();
$query = 'SELECT `id` FROM `tblUsers` WHERE `device_token` != "";';
$user_result = mysql_query($query);

while ($user_row = mysql_fetch_array($user_result, MYSQL_BOTH)) {
	array_push($user_arr, $user_row['id']);
}


function removeElement($arr, $element) {
	$ind = 0;
	foreach ($arr as $key => $val) {
		if ($val == $element) {
			array_splice($arr, $ind, 1);
			break;
		}
		$ind++;
	}
	
	return ($arr);
}

?>

<!DOCTYPE html>
<html lang="en">
	<head>
		<title></title>
		<style type="text/css" rel="stylesheet" media="screen">
			html, body {font-family:Verdana, Arial, sans-serif; font-size:14px;}
		</style>
		
		<script type="text/javascript">
			function submitVote(challengeID, voterID, isCreator) {
				var frmVote = document.getElementById('frmVote');
					frmVote.hidChallengeID.value = challengeID;
					frmVote.hidVoterID.value = voterID;
					frmVote.hidForCreator.value = isCreator;
					frmVote.submit();
			}
		</script>
	</head>
	<body>
		<form id="frmVote" name="frmVote" method="post" action="./submit_vote.php">
			<input id="hidChallengeID" name="hidChallengeID" value="" type="hidden" />
			<input id="hidVoterID" name="hidVoterID" value="" type="hidden" />
			<input id="hidForCreator" name="hidForCreator" value="" type="hidden" />
		</form>
		
		<table cellpadding="0" cellspacing="0" border="1" width="100%">
			<?php while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {				
				$query = 'SELECT * FROM `tblChallenges` WHERE `id` = '. $challenge_row['id'] .';';
				$challenge_obj = mysql_fetch_object(mysql_query($query));
				
				$score_arr = array('creator' => 0, 'challenger' => 0);
				
				$vote_arr = array();
				$query = 'SELECT `user_id`, `challenger_id` FROM `tblChallengeVotes` WHERE `challenge_id` = '. $challenge_obj->id .';';
				$vote_result = mysql_query($query);
				
				while ($vote_row = mysql_fetch_array($vote_result, MYSQL_BOTH)) {
					array_push($vote_arr, $vote_row['user_id']);
					
						if ($vote_row['challenger_id'] == $challenge_obj->creator_id)
							$score_arr['creator']++;						
						else
							$score_arr['challenger']++;
				}
				
				$userID_arr = $user_arr;
				foreach ($vote_arr as $key1 => $val1) {
					foreach ($user_arr as $key2 => $val2) {
						if ($val1 == $val2) {
							$userID_arr = removeElement($userID_arr, $val1);
						}
					}
				}
				
				$ind_rnd = mt_rand(0, count($userID_arr) - 1);
				
				$query = 'SELECT `title` FROM `tblChallengeSubjects` WHERE `id` = '. $challenge_obj->subject_id .';';
				$subject_name = mysql_fetch_object(mysql_query($query))->title;
				
				$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenge_obj->creator_id .';';
				$creator_name = mysql_fetch_object(mysql_query($query))->username;
				
				$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $challenge_obj->challenger_id .';';
				$challenger_name = mysql_fetch_object(mysql_query($query))->username;
				
				echo ("\t\t\t<tr><td align=\"center\" colspan=\"2\"><a name=\"". $challenge_obj->id ."\" />". $creator_name ." has challenged ". $challenger_name ." to a ". $subject_name ." challenge</td></tr>\n");
				echo ("\t\t\t<tr><td align=\"center\" width=\"50%\"><img src=\"". $challenge_obj->creator_img ."_l.jpg\" width=\"256\" height=\"256\" alt=\"\" /></td><td align=\"center\" width=\"50%\"><img src=\"". $challenge_obj->challenger_img ."_l.jpg\" width=\"256\" height=\"256\" alt=\"\" /></td></tr>\n");
				echo ("\t\t\t<tr><td align=\"center\" width=\"50%\"><input type=\"button\" value=\"VOTE!\" onclick=\"submitVote(". $challenge_obj->id .", ". $userID_arr[$ind_rnd] .", 1);\" />". $score_arr['creator'] ."</td><td align=\"center\" width=\"50%\"><input type=\"button\" value=\"VOTE!\" onclick=\"submitVote(". $challenge_obj->id .", ". $userID_arr[$ind_rnd] .", 0);\" />". $score_arr['challenger'] ."</td></tr>\n");
			} ?>
		</table>
	</body>
</html>

<?php

if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>