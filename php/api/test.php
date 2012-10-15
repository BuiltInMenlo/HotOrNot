<?php

$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot') or die("Could not select database.");


$id_arr = array();

$query = 'SELECT `tblChallenges`.`id` FROM `tblChallenges` INNER JOIN `tblChallengeVotes` ON `tblChallenges`.`id` = `tblChallengeVotes`.`challenge_id`;';
$result = mysql_query($query);
while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$id_arr[$row['id']] = 0;
}

$query = 'SELECT `tblChallenges`.`id` FROM `tblChallenges` INNER JOIN `tblChallengeVotes` ON `tblChallenges`.`id` = `tblChallengeVotes`.`challenge_id`;';
$result = mysql_query($query);
while ($row = mysql_fetch_array($result, MYSQL_BOTH)) {
	$id_arr[$row['id']]++;
}

arsort($id_arr);
foreach ($id_arr as $key => $val) {
	echo ("id_arr[". $key ."] = (". $val .")\n");
}


if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>