<?php

$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot-dev') or die("Could not select database.");


$start_date = date('Y-m-d H:i:s', strtotime('2013-01-21 08:00:00'));

// $users_tot = 0;
// for ($i=0; $i<7; $i++)
// 	for ($j=0; $j<24; $j++) {
// 		$end_date = date('Y-m-d H:i:s', strtotime($start_date .' + 1 hour'));
// 	
// 		$query = 'SELECT `id` FROM `tblUsers` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
// 		$user_result = mysql_query($query);
// 		$users_tot += mysql_num_rows($user_result);
// 		
// 		echo ($start_date ."  TO ". $end_date ." ". mysql_num_rows($user_result) .'<br />');
// 		$start_date = $end_date;
// 	}
// 	
// 	echo ($users_tot ."<hr />");
// 	$users_tot = 0;
// }


$users_tot = 0;
$today_tot = 0;
$last_tot = 0;
for ($i=0; $i<7; $i++) {
	$end_date = date('Y-m-d H:i:s', strtotime($start_date .' + 1 day'));
	
	$last_tot = $today_tot;

	$query = 'SELECT `id` FROM `tblUsers` WHERE `device_token` != "" AND `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
	$user_result = mysql_query($query);
	$today_tot = mysql_num_rows($user_result);
	
	if ($last_tot > 0)
		$growth_per = round((($today_tot - $last_tot) / $last_tot) * 100, 2);
	else
		$growth_per = round($today_tot * 100, 2);
	
	$users_tot += $today_tot;
	
	echo ($start_date ."  TO ". $end_date ."\t". $today_tot ."\t". $growth_per ."%<br />");
	$start_date = $end_date;
}

echo ($users_tot ."<hr />");



// echo ("<hr /><hr />");
// 
// $challenges_tot = 0;
// $query = 'SELECT `id`, `username` FROM `tblUsers` WHERE `added` > "'. date('Y-m-d H:i:s', strtotime('2013-01-21 00:00:00')) .'";';
// $result = mysql_query($query);
// 
// while ($user_obj = mysql_fetch_object($result)) {		
// 	$query = 'SELECT `id` FROM `tblChallenges` WHERE `creator_id` = '. $user_obj->id .' OR `challenger_id` = '. $user_obj->id .';';
// 	$challenge_result = mysql_query($query);
// 	$challenges_tot = mysql_num_rows($challenge_result);
// 	
// 	echo ($user_obj->username ." ->> ". $challenges_tot ."<br />");
// }
?>

<html lang="en">
	<head>
		<meta charset="utf-8" />		
		<style type="text/css" rel="stylesheet" media="screen">
			html, body {font-family:Arial, Verdana, sans-serif; font-size:12px;}
			.tdHeader {font-weight:bold;}
		</style>
	</head>
	
	<body>
	</body>
</html>

<?php

if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>