<?php
$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot') or die("Could not select database.");

$query = 'SELECT * FROM `tblChallenges` WHERE `status_id` = 4;';
$challenge_result = mysql_query($query);

while ($challenge_row = mysql_fetch_array($challenge_result, MYSQL_BOTH)) {
	if ($challenge_row['started'] != "0000-00-00 00:00:00") {
		$now_date = date('Y-m-d H:i:s', time());					
		$end_date = date('Y-m-d H:i:s', strtotime($challenge_row['started'] .' + 2 hours'));				   

		if ($now_date > $end_date) {
			$challenge_row['status_id'] = "5";
	
			$query = 'UPDATE `tblChallenges` SET `status_id` = 5 WHERE `id` = '. $challenge_row['id'] .';';
			$result = mysql_query($query);									
		}
	}
}

if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

/*

0	*/12	*	*	*	/usr/local/bin/picchallenge_cleanup.sh

*/
?>