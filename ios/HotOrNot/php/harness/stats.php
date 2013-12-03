<?php

$db_conn = mysql_connect('localhost', 'hotornot_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('hotornot-dev') or die("Could not select database.");


$first_date = date('Y-m-d H:i:s', strtotime('2013-01-21 08:00:00'));
$last_date = date('Y-m-d H:i:s', strtotime($first_date .' + 14 days'));



function snapsPerDay($first_date) {
	$start_date = date('Y-m-d H:i:s', strtotime($first_date));

	for ($i=0; $i<14; $i++) {
		$end_date = date('Y-m-d H:i:s', strtotime($start_date .' + 1 day'));
	
		$query = 'SELECT * FROM `tblChallenges` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$result = mysql_query($query);
		$snaps_tot[0] = mysql_num_rows($result);
		$snaps_tot[1] = 0;
	
		while ($obj = mysql_fetch_object($result)) {
			if ($obj->status_id == 4)
				$snaps_tot[1]++;
		}
	
		echo ("<tr><td>". date('m-d-Y', strtotime($start_date)) ."</td><td align=\"right\">". $snaps_tot[0] ."/". $snaps_tot[1] ."</td><td width=\"32\"> --> </td><td align=\"right\">". ($snaps_tot[0] + $snaps_tot[1]) ."</td></tr>");
		$start_date = $end_date;
	}
}

function votesPerDay($first_date) {
	$start_date = date('Y-m-d H:i:s', strtotime($first_date));

	for ($i=0; $i<14; $i++) {
		$end_date = date('Y-m-d H:i:s', strtotime($start_date .' + 1 day'));
	
		$query = 'SELECT * FROM `tblChallengeVotes` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$result = mysql_query($query);
		$votes_tot = mysql_num_rows($result);

		echo ("<tr><td>". date('m-d-Y', strtotime($start_date)) ."</td><td align=\"right\" colspan=\"3\">$votes_tot</td></tr>");
		$start_date = $end_date;
	}
}

function snapsPerUser($first_date) {
	$start_date = date('Y-m-d H:i:s', strtotime($first_date));
	$end_date = date('Y-m-d H:i:s', strtotime($first_date .' + 14 days'));
	
	$userSnap_arr = array();
	
	$query = 'SELECT * FROM `tblChallenges` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
	$result = mysql_query($query);
	while ($obj = mysql_fetch_object($result)) {
		if ($obj->creator_id != 0)
			$userSnap_arr[$obj->creator_id] = 0;
			
		if ($obj->challenger_id != 0)
			$userSnap_arr[$obj->challenger_id] = 0;
	}
	
	$query = 'SELECT * FROM `tblChallenges` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
	$result = mysql_query($query);
	while ($obj = mysql_fetch_object($result)) {
		if ($obj->creator_id != 0)
			$userSnap_arr[$obj->creator_id]++;
			
		if ($obj->challenger_id != 0)
			$userSnap_arr[$obj->challenger_id]++;
	}
	
	asort($userSnap_arr);
	
	$snap_tot = 0;
	$cnt = 0;
	foreach ($userSnap_arr as $key => $val) {
		$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $key .';';
		$obj = mysql_fetch_object(mysql_query($query));
		$snap_tot += $val;
		
		if ($cnt >= count($userSnap_arr) - 50)
			$topUserSnap_arr[$key] = $val;
			
		echo ("<tr><td>($key) $obj->username</td><td align=\"right\" colspan=\"3\">$val</td></tr>");
		$cnt++;
	}
	
	$snap_ave = $snap_tot / count($userSnap_arr);
	echo ("<tr><td>AVERAGE</td><td align=\"right\" colspan=\"3\">$snap_ave</td></tr></table>");
	echo ("<hr /><a name=\"top_snaps_per_user\" /><a href=\"#top\">TOP</a>");
	echo ("<table><tr><td align=\"center\">USER</td><td colspan=\"3\" align=\"center\">SNAP TOTALS</td></tr>");
	
	$snap_tot = 0;
	foreach ($topUserSnap_arr as $key => $val) {
		$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $key .';';
		$obj = mysql_fetch_object(mysql_query($query));
		$snap_tot += $val;
		
		echo ("<tr><td>($key) $obj->username</td><td align=\"right\" colspan=\"3\">$val</td></tr>");
	}
	
	$snap_ave = $snap_tot / 50;
	echo ("<tr><td>AVERAGE</td><td align=\"right\" colspan=\"3\">$snap_ave</td></tr>");
}

function votesPerUser($first_date) {
	$start_date = date('Y-m-d H:i:s', strtotime($first_date));
	$end_date = date('Y-m-d H:i:s', strtotime($first_date .' + 14 days'));
	
	$userVote_arr = array();
	$query = 'SELECT * FROM `tblChallengeVotes` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
	$result = mysql_query($query);
	while ($obj = mysql_fetch_object($result))
		$userVote_arr[$obj->user_id] = 0;
		
	$query = 'SELECT * FROM `tblChallengeVotes` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
	$result = mysql_query($query);
	while ($obj = mysql_fetch_object($result))
		$userVote_arr[$obj->user_id]++;
	
	asort($userVote_arr);
	$vote_tot = 0;
	$cnt = 0;
	foreach ($userVote_arr as $key => $val) {
		$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $key .';';
		$obj = mysql_fetch_object(mysql_query($query));
		$vote_tot += $val;
		
		if ($cnt >= count($userVote_arr) - 50)
			$topUserVote_arr[$key] = $val;
		
		echo ("<tr><td>($key) $obj->username</td><td align=\"right\" colspan=\"3\">$val</td></tr>");
		$cnt++;
	}
	
	$vote_ave = $vote_tot / count($userVote_arr);
	echo ("<tr><td>AVERAGE</td><td align=\"right\" colspan=\"3\">$vote_ave</td></tr></table>");
	echo ("<hr /><a name=\"top_votes_per_user\" /><a href=\"#top\">TOP</a>");
	echo ("<table><tr><td align=\"center\">USER</td><td colspan=\"3\" align=\"center\">VOTE TOTALS</td></tr>");
	
	$vote_tot = 0;
	foreach ($topUserVote_arr as $key => $val) {
		$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $key .';';
		$obj = mysql_fetch_object(mysql_query($query));
		$vote_tot += $val;
		
		echo ("<tr><td>($key) $obj->username</td><td align=\"right\" colspan=\"3\">$val</td></tr>");
	}
	
	$vote_ave = $vote_tot / 50;
	echo ("<tr><td>AVERAGE</td><td align=\"right\" colspan=\"3\">$vote_ave</td></tr>");
}

function dailyActiveUsers($first_date) {
	$start_date = date('Y-m-d H:i:s', strtotime($first_date));
	
	for ($i=0; $i<14; $i++) {
		$end_date = date('Y-m-d H:i:s', strtotime($start_date .' + 1 day'));
		$userID_arr = array();
		
		$query = 'SELECT * FROM `tblChallenges` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$result = mysql_query($query);
		while ($obj = mysql_fetch_object($result)) {
			if ($obj->creator_id != 0)
				$userID_arr[$obj->creator_id] = true;
				
			if ($obj->challenger_id != 0)
				$userID_arr[$obj->challenger_id] = true;
		}
		
		$query = 'SELECT * FROM `tblChallengeVotes` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$result = mysql_query($query);
		while ($obj = mysql_fetch_object($result)) {
			$userID_arr[$obj->user_id] = true;
		}
		
		$query = 'SELECT * FROM `tblUserPokes` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$result = mysql_query($query);
		while ($obj = mysql_fetch_object($result)) {
			$userID_arr[$obj->poker_id] = true;
		}
		
		echo ("<tr><td>". date('m-d-Y', strtotime($start_date)) ."</td><td align=\"right\" colspan=\"3\">". count($userID_arr) ."</td></tr>");
		$start_date = $end_date;
	}
}

function weeklyActiveUsers($first_date) {
	$start_date = date('Y-m-d H:i:s', strtotime($first_date));
	
	for ($i=0; $i<2; $i++) {
		$end_date = date('Y-m-d H:i:s', strtotime($start_date .' + 7 days'));
		$userID_arr = array();
		
		$query = 'SELECT * FROM `tblChallenges` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$result = mysql_query($query);
		while ($obj = mysql_fetch_object($result)) {
			if ($obj->creator_id != 0)
				$userID_arr[$obj->creator_id] = true;
				
			if ($obj->challenger_id != 0)
				$userID_arr[$obj->challenger_id] = true;
		}
		
		$query = 'SELECT * FROM `tblChallengeVotes` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$result = mysql_query($query);
		while ($obj = mysql_fetch_object($result)) {
			$userID_arr[$obj->user_id] = true;
		}
		
		$query = 'SELECT * FROM `tblUserPokes` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
		$result = mysql_query($query);
		while ($obj = mysql_fetch_object($result)) {
			$userID_arr[$obj->poker_id] = true;
		}
		
		echo ("<tr><td>". date('m-d-Y', strtotime($start_date)) ." / ". date('m-d-Y', strtotime($end_date)) ."</td><td align=\"right\" colspan=\"3\">". count($userID_arr) ."</td></tr>");
		$start_date = $end_date;
	}
}

function monthlyActiveUsers($first_date) {
	$start_date = date('Y-m-d H:i:s', strtotime($first_date));
	$end_date = date('Y-m-d H:i:s', strtotime($start_date .' + 30 days'));
	$userID_arr = array();
		
	$query = 'SELECT * FROM `tblChallenges` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
	$result = mysql_query($query);
	while ($obj = mysql_fetch_object($result)) {
		if ($obj->creator_id != 0)
			$userID_arr[$obj->creator_id] = true;
			
		if ($obj->challenger_id != 0)
			$userID_arr[$obj->challenger_id] = true;
	}
	
	$query = 'SELECT * FROM `tblChallengeVotes` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
	$result = mysql_query($query);
	while ($obj = mysql_fetch_object($result)) {
		$userID_arr[$obj->user_id] = true;
	}
	
	$query = 'SELECT * FROM `tblUserPokes` WHERE `added` > "'. $start_date .'" AND `added` < "'. $end_date .'";';
	$result = mysql_query($query);
	while ($obj = mysql_fetch_object($result)) {
		$userID_arr[$obj->poker_id] = true;
	}
	
	echo ("<tr><td>". date('m-d-Y', strtotime($start_date)) ." / ". date('m-d-Y', strtotime($end_date)) ."</td><td align=\"right\" colspan=\"3\">". count($userID_arr) ."</td></tr>");
}

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
	<a name="top" />
	<h3><a href="#snaps_per_day">Snaps Per Day</a></h3>
	<h3><a href="#votes_per_day">Votes Per Day</a></h3>
	<h3><a href="#snaps_per_user">Snaps Per User</a></h3>
	<h3><a href="#top_snaps_per_user">Top Snaps Per User</a></h3>
	<h3><a href="#votes_per_user">Votes Per User</a></h3>
	<h3><a href="#top_votes_per_user">Top Votes Per User</a></h3>
	<h3><a href="#daily_active_users">Daily Active Users</a></h3>
	<h3><a href="#weekly_active_users">Weekly Active Users</a></h3>
	<h3><a href="#monthly_active_users">Monthly Active Users</a></h3>
	<hr /><hr />
<a name="snaps_per_day" /><a href="#top">TOP</a><table><tr><td width="100" align="center">DATE</td><td colspan="3" align="center">SNAP TOTALS</td></tr>
<?php snapsPerDay('2013-01-21 08:00:00'); ?>

</table><hr /><a name="votes_per_day" /><a href="#top">TOP</a><table><td width="100" align="center">DATE</td><td colspan="3" align="center">VOTE TOTALS</td></tr>
<?php votesPerDay('2013-01-21 08:00:00'); ?>

</table><hr /><a name="snaps_per_user" /><a href="#top">TOP</a><table><td width="100" align="center">USER</td><td colspan="3" align="center">SNAP TOTALS</td></tr>
<?php snapsPerUser('2013-01-21 08:00:00'); ?>

</table><hr /><a name="votes_per_user" /><a href="#top">TOP</a><table><td width="100" align="center">USER</td><td colspan="3" align="center">VOTE TOTALS</td></tr>
<?php votesPerUser('2013-01-21 08:00:00'); ?>

</table><hr /><a name="daily_active_users" /><a href="#top">TOP</a><table><td width="100" align="center">DATE</td><td colspan="3" align="center">USER TOTALS</td></tr>
<?php dailyActiveUsers('2013-01-21 08:00:00'); ?>

</table><hr /><a name="weekly_active_users" /><a href="#top">TOP</a><table><td width="100" align="center">DATE</td><td colspan="3" align="center">USER TOTALS</td></tr>
<?php weeklyActiveUsers('2013-01-21 08:00:00'); ?>

</table><hr /><a name="monthly_active_users" /><a href="#top">TOP</a><table><td width="100" align="center">DATE</td><td colspan="3" align="center">USER TOTALS</td></tr>
<?php monthlyActiveUsers('2013-01-21 08:00:00'); ?>

</table></body>
</html>

<?php



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

/*
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
*/


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


if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>